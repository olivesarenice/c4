#!/bin/bash
set -e

# scripts/fetch.sh
# Unified idempotent fetch for both environment variables and SSH keys.
# Replaces fetch-env.sh and fetch-ssh.sh

echo "=== c4: Unified Secrets Fetcher ==="

# 1. Auth (once)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/bw-auth.sh" ]; then
    source "$SCRIPT_DIR/bw-auth.sh"
    if [ $? -ne 0 ]; then
        exit 1
    fi
else
    echo "Error: bw-auth.sh not found."
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. Environment Variables (Formerly fetch-env.sh)
# ------------------------------------------------------------------------------
echo ""
echo "--- 1. Environment Variables ---"

SECRETS_FILE="$HOME/.config/c4/secrets.env"
mkdir -p "$(dirname "$SECRETS_FILE")"

# Mapping: ENV_VAR:Item Name
declare -a SECRETS=(
    "GITHUB_TOKEN:env-github-token"
    "GEMINI_API_KEY:env-gemini-api-key"
    "GEMINI_AISTUDIO_API_KEY:env-gemini-aistudio-api-key"
    "HETZNER_TOKEN:env-hetzner-token"
)

echo "Syncing Bitwarden Vault..."
bw sync

echo "Fetching secrets into $SECRETS_FILE..."
echo "# c4 Secrets - Generated $(date)" > "$SECRETS_FILE"

for entry in "${SECRETS[@]}"; do
    VAR_NAME="${entry%%:*}"
    ITEM_NAME="${entry#*:}"

    echo -n "  Fetching $VAR_NAME ($ITEM_NAME)... "
    
    # Try fetching as a Note first
    VALUE=$(bw get notes "$ITEM_NAME" 2>/dev/null || true)
    
    if [ -z "$VALUE" ]; then
        echo "❌ Not found or empty."
    else
        echo "export $VAR_NAME=\"$VALUE\"" >> "$SECRETS_FILE"
        echo "✅"
    fi
done

# ------------------------------------------------------------------------------
# 3. SSH Keys (Formerly fetch-ssh.sh)
# ------------------------------------------------------------------------------
echo ""
echo "--- 2. SSH Keys ---"

ITEM_NAME="infra-ssh-key"
SSH_DIR="$HOME/.ssh"
TARGET_FILE="$SSH_DIR/id_rsa"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed."
    exit 1
fi

# 4. Create .ssh if missing
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating $SSH_DIR..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# 5. Fetch
echo "Fetching '$ITEM_NAME' (Notes)..."
# Fetch the full item JSON, then parse the 'notes' field
KEY_CONTENT=$(bw get item "$ITEM_NAME" | jq -r '.notes')

if [ -z "$KEY_CONTENT" ] || [ "$KEY_CONTENT" == "null" ]; then
    echo "Error: Could not retrieve notes from '$ITEM_NAME'."
    exit 1
fi

# 6. Install
if [ -f "$TARGET_FILE" ]; then
    echo "⚠️  $TARGET_FILE already exists."
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

printf "%s\n" "$KEY_CONTENT" > "$TARGET_FILE"
chmod 600 "$TARGET_FILE"

# Regenerate the public key from the private key to keep them in sync
ssh-keygen -y -f "$TARGET_FILE" > "${TARGET_FILE}.pub"
chmod 644 "${TARGET_FILE}.pub"

echo "✅ SSH Key installed to $TARGET_FILE"
echo "✅ Public key regenerated at ${TARGET_FILE}.pub"
echo "Adding to ssh-agent: ssh-add $TARGET_FILE"
ssh-add $TARGET_FILE

echo ""
echo "✅ All secrets fetched successfully."