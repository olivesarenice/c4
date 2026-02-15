#!/bin/bash
set -e

# scripts/fetch-env.sh
# Fetches API tokens/secrets from Bitwarden and writes them to a sourceable .env file.

SECRETS_FILE="$HOME/.config/c4/secrets.env"
mkdir -p "$(dirname "$SECRETS_FILE")"
touch "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"

echo "=== c4: Environment Secret Fetcher ==="

# Auth via module
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

# Define the mapping: ENV_VAR_NAME -> Bitwarden Item Name
# Format: "ENV_VAR:Item Name"
declare -a SECRETS=(
    "GITHUB_TOKEN:env-github-token"
    "GEMINI_API_KEY:env-gemini-api-key"
    "HETZNER_TOKEN:env-hetzner-token"
)

echo "Fetching secrets into $SECRETS_FILE..."

# Clear file initially? Or append? Let's overwrite to keep it clean.
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

echo "Done! Run 'source $SECRETS_FILE' or restart your shell."
