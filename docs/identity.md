# Identity & Secret Management

We use **Bitwarden** as the single source of truth for all secrets.

## The "Master Key": `infra-ssh-privkey`
The SSH key you store in Bitwarden is your **Global Identity**.
It serves two critical purposes:

1.  **Code Access (GitHub)**:
    It allows you to push/pull code from your private repositories (like `c4`). By installing this one key, you don't need to generate new keys for every laptop or VPS.

2.  **Infrastructure Access (Hetzner/VPS)**:
    It allows you to log in to your servers (`ssh root@my-vps`). We will configure your servers to *only* accept this specific key.

### Why not generate a new key for each machine?
Standard security practice suggests unique keys per device. However, for a single-user "Life OS", this creates friction:
*   You have to manually add every new key to GitHub.
*   You have to manually add every new key to your VPS `authorized_keys`.
*   **Our Approach**: One strong, guarded key (in Bitwarden) that we deploy to our trusted devices.

## Setup Workflow

1.  **Login**:
    ```bash
    bw login
    export BW_SESSION=$(bw unlock --raw)
    ```

2.  **Fetch Keys**:
    Run the helper script:
    ```bash
    ./scripts/fetch.sh
    ```
