---
description: how to create a new project from scratch
---

## Steps

1. Create the project directory and init git
```bash
mkdir ~/projects/<name> && cd ~/projects/<name> && git init
```

2. Create a `.agent/` folder for project-level Antigravity config
```bash
mkdir -p .agent/workflows .agent/skills
```

3. Copy global skills from c4 into the project
```bash
cp -r ~/projects/c4/.agent/skills .agent/
```

4. Create a project-level `README.md` with goals and context

5. If Python project, init with uv:
```bash
uv init .
```

6. If Node project, init with npm/pnpm:
```bash
pnpm init
```
