# c4: Digital Life OS

**c4** is a personal infrastructure-as-code repository designed to bootstrap and manage a consistent development environment across multiple machines (macOS and Linux/WSL).

## Overview

This repository automates the setup of:
- **Core System**: Zsh configuration, Starship prompt, and essential utilities via Homebrew.
- **Dev Toolchain**: Python (`uv`), Node.js (`fnm`), and modern CLI tools (`ripgrep`, `bat`, `fzf`, `jq`).
- **Identity & Secrets**: Secure access to SSH keys and API tokens using Bitwarden.
- **Desktop Config**: VS Code / Antigravity profiles and settings.

## Getting Started

### Prerequisites
- macOS or a Linux/WSL2 environment.
- **Bitwarden CLI** (`bw`) installed and logged in.

### Quick Start
To bootstrap a new machine, follow the detailed instructions in [docs/manual_setup.md](docs/manual_setup.md).

In short:
```bash
git clone https://github.com/olivesarenice/c4
cd c4
./bootstrap.sh
```

## Structure

- `bootstrap.sh`: The main entry point for provisioning.
- `capabilities/`: Modular installation scripts.
    - `core/`: Base system (brew, zsh). Platform-specific `zshrc.mac` / `zshrc.wsl`.
    - `dev/`: Development tools (languages, CLIs).
    - `desktop/`: GUI application configs (VS Code).
- `scripts/`: Helper scripts.
    - `fetch.sh`: **Unified command** to refresh all secrets (SSH keys + env vars).
    - `bw-auth.sh`: Bitwarden authentication helper.
- `docs/`: Documentation and setup guides.

## License
MIT
