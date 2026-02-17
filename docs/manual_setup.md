# Manual Setup & Bootstrapping Guide

This document details the **one-time setup** required to provision a new machine (Windows/WSL or Linux) with the `c4` Digital Life OS.

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

**Linux / WSL**:
```bash
# Download & Install
wget "https://github.com/bitwarden/clients/releases/download/cli-v2024.1.0/bw-linux-2024.1.0.zip"
unzip bw-linux-*.zip && sudo mv bw /usr/local/bin/ && chmod +x /usr/local/bin/bw

# Verify
bw --version
```

## 3. Bootstrap

Once prerequisites are met, the `bootstrap.sh` script automates the rest.

### A. Run Bootstrap
```bash
# Create directory if needed
mkdir -p ~/projects
cd ~/projects
# Clone (if not already there) - adjust URL as needed
git clone https://github.com/olivesarenice/c4
cd c4
./bootstrap.sh
```
**What it does:**
1.  **Installs Core Tools**: Linuxbrew, Zsh, Starship, basic utils.
2.  **Installs Dev Chain**: `uv` (Python), `fnm` (Node), `ripgrep`, `bat`, `fzf`, etc.
3.  **Configures Shell**: Links a standardized `.zshrc`.
4.  **Sets up Identity**: Prompts you to log in to Bitwarden and fetches your **SSH Keys** (`infra-ssh-key`).

### B. Fetch Secrets (`fetch-env`)
After bootstrapping, you likely need your API keys (OpenAI, GitHub, etc.) in your environment.

Run the environment fetcher:
```bash
./scripts/fetch.sh
```
**What it does:**
*   unlocks Bitwarden (using the shared `bw-auth` logic).
*   Retrieves secrets mapped in the script (e.g., `GITHUB_TOKEN`).
*   Writes them to a secure file: `~/.config/c4/secrets.env`.
*   *Note*: This file is automatically sourced by your new `.zshrc`.

**Required Bitwarden Items:**
Ensure you have created these items in Bitwarden (Item Name -> Secret):
*   `env-github-token` -> `GITHUB_TOKEN`
*   `env-gemini-api-key` -> `GEMINI_API_KEY`
*   `env-hetzner-token` -> `HETZNER_TOKEN`

## 4. Manual Config Migration

### VS Code Settings
VS Code settings are personal and often specific to the machine's UI.
*   **Action**: Copy your existing `settings.json` and `keybindings.json` to:
    *   `~/projects/c4/capabilities/desktop/default.code-profile` (This profile can be imported into VS Code)
*   The `c4` repo effectively becomes the backup for these.
