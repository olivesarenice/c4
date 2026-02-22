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

# 1. Core Capability (Zsh, oh-my-posh, plugins)
echo -e "${YELLOW}[1/5] Installing Core System...${NC}"
bash ./capabilities/core/install.sh

# 2. Dev Capability (uv, fnm, Docker)
echo -e "${YELLOW}[2/5] Installing Dev Toolchain...${NC}"
bash ./capabilities/dev/install.sh

# 3. Identity (Bitwarden)
echo -e "${YELLOW}[3/5] Authenticating Identity...${NC}"

# Source the reusable auth script
# We use . because we are inside the repo root when running bootstrap
if [ -f "./scripts/bw-auth.sh" ]; then
    source ./scripts/bw-auth.sh
else
    echo "⚠️  scripts/bw-auth.sh not found."
fi

# 4. Fetch Secrets (SSH keys + env vars)
echo -e "${YELLOW}[4/5] Fetching Secrets...${NC}"
echo "Do you want to fetch secrets from Bitwarden (SSH keys + API keys)?"
read -p "Fetch secrets? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/fetch.sh
fi

# 5. VSCode Profile
echo -e "${YELLOW}[5/6] VSCode Profile${NC}"
echo "📦 Import VS Code profile manually:"
echo "   1. Open VS Code → Ctrl+Shift+P"
echo "   2. 'Profiles: Import Profile...'"
echo "   3. Select: $(pwd)/capabilities/desktop/default.code-profile"
echo ""
echo "💡 To update profile: Ctrl+Shift+P → 'Profiles: Export Profile...' → overwrite the file → git commit"
echo ""

# 6. Agent Config Sync (Rules, Workflows, Skills → global Antigravity dirs)
echo -e "${YELLOW}[6/6] Syncing Agent Config...${NC}"
if [ -f "./scripts/sync-agents.sh" ]; then
    bash ./scripts/sync-agents.sh
else
    echo "⚠️  scripts/sync-agents.sh not found — skipping agent sync."
fi

# Done
echo -e "${GREEN}=== Bootstrap Complete ===${NC}"
echo "Please restart your shell to apply changes."
