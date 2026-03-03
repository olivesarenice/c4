#!/bin/bash
set -e

# capabilities/core/install.sh
# Installs core system utilities using Homebrew.
# Works on both macOS and Linux/WSL.

echo "--- Installing Core Capability (via Brew) ---"

# ---------------------------------------------------------------------------
# Detect OS
# ---------------------------------------------------------------------------
OS="$(uname -s)"
echo "Detected OS: $OS"

# ---------------------------------------------------------------------------
# 1. Install System Dependencies (Linux only — macOS ships with what we need)
# ---------------------------------------------------------------------------
if [ "$OS" = "Linux" ]; then
    if [ -f /etc/debian_version ]; then
        if ! command -v git &> /dev/null || ! command -v curl &> /dev/null; then
            echo "Installing git/curl via apt (required for brew)..."
            sudo apt-get update && sudo apt-get install -y build-essential curl git
        fi
    fi
fi

# ---------------------------------------------------------------------------
# 2. Install Homebrew
# ---------------------------------------------------------------------------
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path temporarily for this script
    if [ "$OS" = "Darwin" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    fi
else
    echo "Brew is already installed."
    eval "$($(which brew) shellenv)"
fi

# ---------------------------------------------------------------------------
# 3. Install Core Tools via Brew
# ---------------------------------------------------------------------------
echo "Brewing core tools..."
brew install oh-my-posh zsh-autosuggestions zsh-syntax-highlighting

# ---------------------------------------------------------------------------
# 4. Change Shell to Zsh
# ---------------------------------------------------------------------------
if ! command -v zsh &> /dev/null; then
    brew install zsh
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "⚠️  Your default shell is not Zsh."
    echo "Run: sudo sh -c 'echo $(which zsh) >> /etc/shells' && chsh -s $(which zsh)"
fi

# ---------------------------------------------------------------------------
# 5. Link .zshrc (platform-specific)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ZSHRC="$HOME/.zshrc"

if [ "$OS" = "Darwin" ]; then
    C4_ZSHRC="$SCRIPT_DIR/zshrc.mac"
else
    C4_ZSHRC="$SCRIPT_DIR/zshrc.wsl"
fi

if [ ! -f "$C4_ZSHRC" ]; then
    echo "❌ Platform zshrc not found: $C4_ZSHRC"
    exit 1
fi

if [ -f "$TARGET_ZSHRC" ] && [ ! -L "$TARGET_ZSHRC" ]; then
    echo "Backing up existing .zshrc to .zshrc.bak..."
    mv "$TARGET_ZSHRC" "$TARGET_ZSHRC.bak"
fi

echo "Linking .zshrc → $(basename "$C4_ZSHRC")..."
ln -sf "$C4_ZSHRC" "$TARGET_ZSHRC"

echo "✅ Core capability installed."
