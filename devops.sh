#!/usr/bin/env bash
set -eu

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
else
  echo "Error: /etc/os-release not found." >&2
  exit 1
fi

os_id="${ID:-}"
os_like="${ID_LIKE:-}"

if [[ "$os_id" == "debian" || "$os_id" == "ubuntu" ]] || [[ " $os_like " =~ [[:space:]](debian|ubuntu)[[:space:]] ]]; then
  os_family="debian"
elif [[ "$os_id" == "fedora" ]] || [[ " $os_like " =~ [[:space:]]fedora[[:space:]] ]]; then
  os_family="fedora"
else
  echo "Error: Unsupported OS ($os_id). Debian, Ubuntu, and Fedora are supported." >&2
  exit 1
fi
echo "Running on $PRETTY_NAME ($os_id)..."


echo "=== 1. Installing Prerequisites ==="

if [[ "$os_family" == "debian" ]]; then
    sudo apt-get update
    sudo apt-get install -y curl unzip gnupg lsb-release ca-certificates software-properties-common
else
    sudo dnf install -y curl unzip gnupg2
fi

echo "=== 2. Installing AWS CLI v2 ==="
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    AWS_ARCH="x86_64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    AWS_ARCH="aarch64"
else
    echo "Unsupported architecture for AWS CLI: $ARCH"
    exit 1
fi

TMP_DIR=$(mktemp -d)
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$AWS_ARCH.zip" -o "$TMP_DIR/awscliv2.zip"
unzip -q "$TMP_DIR/awscliv2.zip" -d "$TMP_DIR"
sudo "$TMP_DIR/aws/install" --update
rm -rf "$TMP_DIR"

echo "=== 3. Installing Terraform ==="
if [[ "$os_family" == "debian" ]]; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update -y
    sudo apt-get install -y terraform
else
    sudo curl -fsSL https://rpm.releases.hashicorp.com/fedora/hashicorp.repo -o /etc/yum.repos.d/hashicorp.repo
    sudo dnf install -y terraform
fi

echo "=== 4. Installing Ansible ==="
if [[ "$os_family" == "debian" ]]; then
    sudo apt-get install -y ansible
else
    sudo dnf install -y ansible-core
fi

echo "=== 5. Verifying Installations ==="
aws --version
terraform -version
ansible --version
echo "All tools installed successfully!"
