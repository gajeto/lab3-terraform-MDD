#!/bin/bash
set -euxo pipefail

dnf -y update
dnf -y install python3 python3-pip amazon-ssm-agent
systemctl enable --now amazon-ssm-agent || true

# Install polars in a venv
VENV_DIR="/opt/app-venv"
if [[ ! -d "$VENV_DIR" ]]; then
  /usr/bin/python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install polars --only-binary=:all:
deactivate

echo "Terraform configuration complete: EC2 instance with python and polars installed"