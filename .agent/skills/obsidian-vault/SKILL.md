---
name: obsidian-vault
description: Access the USER's personal Obsidian knowledge vault — location, read/write rules, and navigation guidance
---

# Obsidian Vault Skill

## Vault Location

The vault path depends on the OS of the current device:

| OS      | Vault Path                              |
|---------|-----------------------------------------|
| Windows | `C:\Users\Oliver\Documents\personal`      |
| macOS   | `~/Documents/personal`                    |

Detect the OS from the user's system context before constructing any paths.

## Agent Context Directory

The vault always contains a `_agent/` directory with context files (instructions, templates, schemas, etc.). **Before doing anything with the vault, read all files in `<vault>/_agent/` and follow any directives they contain.**

- Windows: `C:\Users\Oliver\Desktop\personal\_agent\`
- macOS: `~/Documents/personal/_agent/`

## Read / Write Rules

- **READ**: All notes are readable for context. Always run `find_by_name` or `list_dir` first to understand the current structure before navigating — do not assume folder names.
- **WRITE**: Only write to the `AI Inbox` folder. Use descriptive filenames: `YYYY-MM-DD-topic-slug.md`.
- Never modify or delete files outside `AI Inbox`.

## Note Format

Obsidian markdown with optional YAML frontmatter:
```markdown
---
tags: [tag1, tag2]
created: 2026-02-22
---

# Title

Content...
```

- Internal links: `[[Note Title]]`
- Tags: `#tag` inline or `tags:` in frontmatter

## Common Tasks

**Explore structure:** `list_dir <vault>`

**Search content:** `grep_search` against the vault path.

**Read a note:** `view_file` with the full OS-appropriate path.

**Create a note:** `write_to_file` → `<vault>/AI Inbox/<filename>.md`
