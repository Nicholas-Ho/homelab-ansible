#!/bin/bash

## Specify Ansible mode
if [[ $# -eq 0 ]]; then
  echo "Error: no arguments provided"
  echo "Usage: $0 --local|--remote"
  if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    return 1
  else
    exit 1
  fi
fi

case "$1" in
    --local)
      INVENTORY_INI="ansible/inventory/local.ini"
      ANSIBLE_CMD="ansible-playbook -i $INVENTORY_INI ansible/playbook.yaml -K -u '$(whoami)'"
      ;;
    --remote)
      INVENTORY_INI="ansible/inventory/remote.ini"
      ANSIBLE_CMD="ansible-playbook -i $INVENTORY_INI ansible/playbook.yaml -k"
      ;;
esac

# Check for python
if ! command -v python3 >/dev/null 2>&1; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y python3 python3-venv python3-pip
    elif [[ "$ID" == "arch" ]]; then
        sudo pacman -S python python-pip
    fi
fi

# venv setup
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate

# Guard against PATH issues
export PATH="$HOME/.local/bin:$PATH"

python3 -m pip install --upgrade pip
python3 -m pip install ansible
$ANSIBLE_CMD

deactivate
