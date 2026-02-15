#!/bin/bash
set -e

# capabilities/core/install.sh
# Installs core system utilities using Homebrew (Linuxbrew).

echo "--- Installing Core Capability (via Brew) ---"

# 1. Install System Dependencies (Minimal for loading Brew)
if [ -f /etc/debian_version ]; then
   # We still need these to run the brew installer
   if ! command -v git &> /dev/null || ! command -v curl &> /dev/null; then
       echo "Installing git/curl via apt (required for brew)..."
       sudo apt-get update && sudo apt-get install -y build-essential curl git
   fi
fi

# 2. Install Linuxbrew
if ! command -v brew &> /dev/null; then
    echo "Installing Linuxbrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to path temporarily for this script
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
else
    echo "Brew is already installed."
    eval "$($(which brew) shellenv)"
fi

# 3. Install Core Tools via Brew
echo "Brewing core tools..."
brew install oh-my-posh zsh-autosuggestions zsh-syntax-highlighting

# 4. Change Shell to Zsh
if ! command -v zsh &> /dev/null; then
    brew install zsh
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "⚠️  Your default shell is not Zsh."
    # Note: chsh might fail if zsh is not in /etc/shells. 
    # We leave this manual or add logic to append to /etc/shells.
    echo "Run: sudo sh -c 'echo $(which zsh) >> /etc/shells' && chsh -s $(which zsh)"
fi

# 5. Link .zshrc
C4_ZSHRC="$HOME/projects/c4/capabilities/core/zshrc"
TARGET_ZSHRC="$HOME/.zshrc"

if [ -f "$TARGET_ZSHRC" ] && [ ! -L "$TARGET_ZSHRC" ]; then
    echo "Backing up existing .zshrc to .zshrc.bak..."
    mv "$TARGET_ZSHRC" "$TARGET_ZSHRC.bak"
fi

echo "Linking .zshrc..."
ln -sf "$C4_ZSHRC" "$TARGET_ZSHRC"

echo "✅ Core capability installed."
