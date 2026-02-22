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
└── .agent/                   ← Antigravity global config (rules, workflows, skills)
```

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

