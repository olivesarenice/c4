#!/bin/bash
set -e

# fetch-ssh.sh
# Retrieves the SSH Private Key from Bitwarden and installs it.
# Usage: ./fetch-ssh.sh

echo "=== c4: SSH Key Fetcher ==="

# 1. Auth via module
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

# 2. Config
ITEM_NAME="infra-ssh-key"
SSH_DIR="$HOME/.ssh"
TARGET_FILE="$SSH_DIR/id_rsa"

# 3. Check for jq (Required for parsing fields)
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it (sudo apt install jq)."
    exit 1
fi

# 4. Create .ssh if missing
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating $SSH_DIR..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# 5. Fetch
echo "Fetching '$ITEM_NAME'..."
# Fetch the item JSON, then extract the custom field named 'private-key'
KEY_CONTENT=$(bw get item "$ITEM_NAME" | jq -r '.fields[] | select(.name=="private-key").value')

if [ -z "$KEY_CONTENT" ] || [ "$KEY_CONTENT" == "null" ]; then
    echo "Error: Could not retrieve 'private-key' field from '$ITEM_NAME'."
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

echo "✅ SSH Key installed to $TARGET_FILE"
echo "You may now need to add it to your agent: ssh-add $TARGET_FILE"
