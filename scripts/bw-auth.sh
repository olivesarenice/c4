#!/bin/bash
# scripts/bw-auth.sh
# Reusable logic to authenticate and unlock Bitwarden.
# Usage: source ./scripts/bw-auth.sh

if ! command -v bw &> /dev/null; then
    echo "⚠️  Bitwarden CLI ('bw') not found."
    return 1
fi

# Unset stale session to prevent errors
unset BW_SESSION

# Check Status
BW_STATUS=$(bw status | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

if [ "$BW_STATUS" == "unauthenticated" ]; then
    echo "🔓 You are not logged in."
    bw login
    BW_STATUS=$(bw status | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
fi

if [ "$BW_STATUS" == "locked" ]; then
    echo "🔐 Vault is locked. Enter Master Password."
    # Capture output but check exit code
    TEMP_SESSION=$(bw unlock --raw)
    RET=$?
    
    if [ $RET -ne 0 ]; then
            echo "❌ Bitwarden unlock failed."
            return 1
    fi
    export BW_SESSION="$TEMP_SESSION"
fi

echo "✅ Bitwarden Session Active."
return 0
