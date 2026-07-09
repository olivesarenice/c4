---
name: c4-infrastructure
description: Knowledge about the c4 Digital Life OS repo — structure, patterns, and conventions for modifying it
---

# c4 Infrastructure Skill

## What c4 Is
Personal infrastructure-as-code repo. Bootstraps and manages consistent dev environments across Linux/WSL machines.

## Key Paths
```
c4/
├── bootstrap.sh              ← Main provisioning entry point
├── capabilities/
│   ├── core/                 ← Zsh, Starship, Homebrew
│   ├── dev/                  ← Python (uv), Node (fnm), CLI tools
│   └── desktop/              ← VS Code profiles + settings
├── scripts/
│   ├── fetch.sh              ← Unified secrets refresh (SSH + env vars from Bitwarden)
│   └── bw-auth.sh            ← Bitwarden auth helper
├── knowledge/                ← Reference docs (personality, assistant context) — no fixed structure
├── docs/project_templates/   ← Prescriptive tech stack + style guide templates for new projects
└── .agent/                   ← Antigravity global config (rules, workflows, skills)
```

## Project Templates
`docs/project_templates/` contains self-contained template folders that can be copy-pasted into other repos. Each folder provides the full stack + style context an agent needs to scaffold an application.

- **`DATA_APP_TEMPLATE_1/`** — Data-heavy app template (Psyche Network design language)
  - `TECH_STACK.md` — FastAPI + React + ShadCN + Redis/TaskIQ + pgvector, deployed on Hetzner/Coolify. Target: <1K users.
  - `STYLE_GUIDE.md` — Retro-terminal phosphor display theme: ShadCN CSS variables, JSX components (TerminalCard, DataTable, ActionButton, JaggedChart), page skeleton, layout rules, agent constraints.

## Secrets Pattern
- All secrets stored in Bitwarden.
- `scripts/fetch.sh` fetches and writes them to `.env` or `~/.ssh/`.
- Never hardcode secrets. Never commit `.env` (gitignored).
- Template pattern: keep `*.template` files with `${VAR}` placeholders, render at fetch time.

## Adding a New Capability
1. Create `capabilities/<category>/<name>.sh`
2. Make it idempotent (safe to re-run)
3. Source or call it from `bootstrap.sh`
4. Document in `docs/manual_setup.md`

## Antigravity IDE Integration
- **macOS Application**: Installed at `/Applications/Antigravity IDE.app`
- **CLI Alias (`agy`)**: Configured in `zshrc.mac` pointing to `"/Applications/Antigravity IDE.app/Contents/Resources/app/bin/antigravity-ide"`
- **Settings Directory**: `~/Library/Application Support/Antigravity IDE/User/`
- **WSL/Linux Alias**: `antigravity` pointing to Windows-installed Antigravity.

