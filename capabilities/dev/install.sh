#!/bin/bash
set -e

# capabilities/dev/install.sh
# Installs development tools and runtimes.

echo "--- Installing Dev Capability ---"

# Ensure brew is available
if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -d "$HOME/.linuxbrew/bin" ]; then
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
elif command -v brew &> /dev/null; then
    eval "$($(which brew) shellenv)"
else
    echo "❌ Brew not found. Please run capabilities/core/install.sh first."
    exit 1
fi

echo "Brewing dev tools..."

# 1. Runtimes
# Python (uv)
brew install uv

# Node.js (fnm)
brew install fnm

# 2. CLI Tools
brew install ripgrep
brew install bat
brew install fzf
brew install jq
brew install yq

# 3. Docker (Message only, as it varies significantly)
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker is not installed."
    echo "   Please install Docker Desktop or Engine manually for your specific OS."
    echo "   See: https://docs.docker.com/engine/install/"
else
    echo "✅ Docker is already installed."
fi

# 4. Setup completions/environment if needed
# (Most are handled by .zshrc, but we can verify)

echo "✅ Dev capability installed."
