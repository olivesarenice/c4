#!/bin/bash
set -e

# scripts/sync-agents.sh
# Syncs c4/.agent/ (rules, workflows, skills) to the global Antigravity directories.
# Works on both macOS and WSL/Windows.
#
# Global Antigravity paths:
#   macOS:
#     RULES:     ~/.gemini/GEMINI.md
#     WORKFLOWS: ~/.gemini/antigravity/global_workflows/<workflow>.md
#     SKILLS:    ~/.gemini/antigravity/skills/<skill-folder>/SKILL.md
#
#   Windows (via WSL):
#     Same structure under /mnt/c/Users/<user>/.gemini/

echo "=== c4: Agent Config Sync ==="

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
C4_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENT_DIR="$C4_DIR/.agent"

# ---------------------------------------------------------------------------
# Detect OS and set target paths
# ---------------------------------------------------------------------------

OS="$(uname -s)"

if [ "$OS" = "Darwin" ]; then
    # macOS — target is just ~/.gemini
    GEMINI_DIR="$HOME/.gemini"
    echo "Platform      : macOS"
else
    # WSL — target is Windows-side ~/.gemini via /mnt/c
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    if [ -z "$WIN_USER" ]; then
        echo "Error: Could not detect Windows username. Are you running from WSL?"
        exit 1
    fi
    WIN_HOME="/mnt/c/Users/$WIN_USER"
    GEMINI_DIR="$WIN_HOME/.gemini"
    echo "Platform      : WSL"
    echo "Windows user  : $WIN_USER"
fi

TARGET_RULES="$GEMINI_DIR/GEMINI.md"
TARGET_WORKFLOWS="$GEMINI_DIR/antigravity/global_workflows"
TARGET_SKILLS="$GEMINI_DIR/antigravity/skills"

echo "Gemini dir    : $GEMINI_DIR"
echo ""

# ---------------------------------------------------------------------------
# 1. Rules → ~/.gemini/GEMINI.md
# ---------------------------------------------------------------------------
echo "--- 1. Rules ---"

RULES_SOURCE="$AGENT_DIR/rules/global.md"

if [ ! -f "$RULES_SOURCE" ]; then
    echo "⚠️  No rules file found at $RULES_SOURCE — skipping."
else
    mkdir -p "$GEMINI_DIR"
    cp "$RULES_SOURCE" "$TARGET_RULES"
    echo "✅ Rules synced → $TARGET_RULES"
fi

# ---------------------------------------------------------------------------
# 2. Workflows → ~/.gemini/antigravity/global_workflows/
# ---------------------------------------------------------------------------
echo ""
echo "--- 2. Workflows ---"

WORKFLOWS_SOURCE="$AGENT_DIR/workflows"

if [ ! -d "$WORKFLOWS_SOURCE" ] || [ -z "$(ls -A "$WORKFLOWS_SOURCE"/*.md 2>/dev/null)" ]; then
    echo "⚠️  No workflows found at $WORKFLOWS_SOURCE — skipping."
else
    mkdir -p "$TARGET_WORKFLOWS"
    for workflow in "$WORKFLOWS_SOURCE"/*.md; do
        name=$(basename "$workflow")
        cp "$workflow" "$TARGET_WORKFLOWS/$name"
        echo "✅ $name → $TARGET_WORKFLOWS/$name"
    done
fi

# ---------------------------------------------------------------------------
# 3. Skills → ~/.gemini/antigravity/skills/
# ---------------------------------------------------------------------------
echo ""
echo "--- 3. Skills ---"

SKILLS_SOURCE="$AGENT_DIR/skills"

if [ ! -d "$SKILLS_SOURCE" ] || [ -z "$(ls -A "$SKILLS_SOURCE" 2>/dev/null)" ]; then
    echo "⚠️  No skills found at $SKILLS_SOURCE — skipping."
else
    mkdir -p "$TARGET_SKILLS"
    for skill_dir in "$SKILLS_SOURCE"/*/; do
        skill_name=$(basename "$skill_dir")
        skill_file="$skill_dir/SKILL.md"
        if [ ! -f "$skill_file" ]; then
            echo "⚠️  $skill_name: missing SKILL.md — skipping."
            continue
        fi
        mkdir -p "$TARGET_SKILLS/$skill_name"
        # Copy entire skill folder (SKILL.md + any supporting files)
        cp -r "$skill_dir/." "$TARGET_SKILLS/$skill_name/"
        echo "✅ $skill_name/ → $TARGET_SKILLS/$skill_name/"
    done
fi

echo ""
echo "✅ Agent sync complete."

if [ "$OS" != "Darwin" ]; then
    echo ""
    echo "Reminder: ~/.gemini/GEMINI.md content should also be pasted into:"
    echo "  VS Code → User Settings JSON → \"gemini.codeAssist.userContext\""
fi
