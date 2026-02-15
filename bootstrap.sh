#!/bin/bash
set -e

# bootstrap.sh
# The "One Script" to rule them all.

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}=== c4: Digital Life Installer ===${NC}"

# 1. Core Capability (Zsh, Starship)
echo -e "${YELLOW}[1/4] Installing Core System...${NC}"
bash ./capabilities/core/install.sh

# 2. Dev Capability (uv, fnm, Docker)
echo -e "${YELLOW}[2/4] Installing Dev Toolchain...${NC}"
bash ./capabilities/dev/install.sh

# 3. Identity (Bitwarden)
echo -e "${YELLOW}[3/4] Authenticating Identity...${NC}"

# Source the reusable auth script
# We use . because we are inside the repo root when running bootstrap
if [ -f "./scripts/bw-auth.sh" ]; then
    source ./scripts/bw-auth.sh
else
    echo "⚠️  scripts/bw-auth.sh not found."
fi

echo "Do you want to fetch SSH keys from Bitwarden?"
read -p "Fetch keys? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/fetch-ssh.sh
fi

# 4. Success
echo -e "${GREEN}=== Bootstrap Complete ===${NC}"
echo "Please restart your shell to apply changes."
