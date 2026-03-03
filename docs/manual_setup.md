# Manual Setup & Bootstrapping Guide

This document details the **one-time setup** required to provision a new machine (macOS, Windows/WSL, or Linux) with the `c4` Digital Life OS.

## 1. Prerequisites (Windows Users Only)

If you are on Windows, you must first set up WSL2. Open **PowerShell (Admin)** and run:

1.  **Install WSL2**:
    ```powershell
    wsl --install ubuntu
    # Restart computer if prompted, then:
    wsl --set-default Ubuntu
    ```

2.  **Install Antigravity**:
    *   Download and install the Antigravity application on Windows.

3.  **Configure WSL Interop (Fix `wslu` bug)**:
    Open your **Ubuntu Terminal** and run these commands to ensure Windows apps (like browsers) can open from Linux:
    ```bash
    # Update /etc/wsl.conf
    sudo sh -c 'echo "[interop]\nenabled=true\nappendWindowsPath=true" >> /etc/wsl.conf'

    # Apply Systemd Fix for wslu
    sudo tee /etc/systemd/system/wsl-interop-fix.service >/dev/null <<'EOF'
    [Unit]
    Description=Add legacy WSLInterop binfmt entry for wslu tools
    After=systemd-binfmt.service
    Wants=systemd-binfmt.service
    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c 'echo ":WSLInterop:M::MZ::/init:P" | tee /proc/sys/fs/binfmt_misc/register'
    RemainAfterExit=yes
    [Install]
    WantedBy=multi-user.target
    EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable --now wsl-interop-fix.service
    ```
    *Restart WSL (`wsl --shutdown`) after this.*

## 2. Install Bitwarden CLI (Required)

The `c4` environment relies on **Bitwarden** for all secrets (SSH keys, API tokens). You must install the CLI manually.

**macOS**:
```bash
brew install bitwarden-cli
bw --version   # verify
```

**Linux / WSL**:

Download the latest release from: https://github.com/bitwarden/clients/releases?q=cli&expanded=true

```bash
# Replace <version> with the version from the releases page, e.g. 2024.12.0
wget "https://github.com/bitwarden/clients/releases/download/cli-v<version>/bw-linux-<version>.zip"
unzip bw-linux-*.zip && sudo mv bw /usr/local/bin/ && chmod +x /usr/local/bin/bw

# Verify
bw --version
```

## 3. Bootstrap

Once prerequisites are met, the `bootstrap.sh` script automates the rest.

### A. Install Git

**macOS**: Git ships with Xcode Command Line Tools (`xcode-select --install`).

**Linux/WSL**: Fresh Ubuntu images may not have git:
```bash
sudo apt-get update && sudo apt-get install -y git
git --version   # verify
```

### B. Clone the Repo

> **Note**: On a fresh machine you won't have SSH keys yet. Use HTTPS for the initial clone, then switch the remote to SSH after `fetch.sh` has deposited your keys.

```bash
mkdir -p ~/projects
cd ~/projects
# First-time clone via HTTPS (no SSH key required)
git clone https://github.com/olivesarenice/c4
cd c4
```

Once SSH keys are in place (after step 4 below), switch to SSH:
```bash
git remote set-url origin git@github.com:olivesarenice/c4.git
```

### B. Run Bootstrap
```bash
./bootstrap.sh
```
**What it does:**
1.  **Installs Core Tools**: Homebrew, Zsh, Starship, basic utils.
2.  **Installs Dev Chain**: `uv` (Python), `fnm` (Node), `ripgrep`, `bat`, `fzf`, etc.
3.  **Configures Shell**: Links the platform-appropriate `.zshrc` (`zshrc.mac` on macOS, `zshrc.wsl` on Linux).
4.  **Sets up Identity**: Prompts you to log in to Bitwarden and fetches your **SSH Keys** (`infra-ssh-key`).

### C. Fetch Secrets (`fetch.sh`)
`bootstrap.sh` will prompt you to run `./scripts/fetch.sh` automatically. If you skipped it, run it manually:
```bash
./scripts/fetch.sh
```
**What it does:**
*   Unlocks Bitwarden (using the shared `bw-auth` logic).
*   Fetches your SSH keys and writes them to `~/.ssh/`.
*   Retrieves env secrets (e.g., `GITHUB_TOKEN`) and writes them to `~/.config/c4/secrets.env`.
*   *Note*: `secrets.env` is automatically sourced by your new `.zshrc`.

**Required Bitwarden Items:**
Ensure you have created these items in Bitwarden (Item Name -> Secret):
*   `env-github-token` -> `GITHUB_TOKEN`
*   `env-gemini-api-key` -> `GEMINI_API_KEY`
*   `env-hetzner-token` -> `HETZNER_TOKEN`

## 4. Manual Config Migration

### VS Code Profile (WSL/Linux)

The repo ships a full VS Code profile at `capabilities/desktop/default.code-profile`.

**To apply on a new machine:**
1. Open VS Code → `Ctrl+Shift+P` → "Profiles: Import Profile..."
2. Select `capabilities/desktop/default.code-profile`

**To update the profile after making config changes:**
1. `Ctrl+Shift+P` → "Profiles: Export Profile..."
2. Overwrite `capabilities/desktop/default.code-profile`
3. `git commit`

> **Tip**: When exporting, uncheck "UI State" to keep diffs clean.

### Antigravity Settings (macOS)

On macOS with Antigravity, editor settings live at:
```
~/Library/Application Support/Antigravity/User/settings.json
```

The settings were extracted from the VS Code profile above. To update, edit the file directly or use `Cmd+,` in Antigravity.
