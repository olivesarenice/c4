---
name: obsidian-vault
description: Access the USER's personal Obsidian knowledge vault — location, read/write rules, and navigation guidance
---

# Obsidian Vault Skill

## Vault Location

| Context | Path |
|---|---|
| Windows | `C:\Users\USER\Desktop\personal` |
| WSL | `/mnt/c/Users/USER/Desktop/personal` |

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

**Explore structure:** `list_dir /mnt/c/Users/USER/Desktop/personal`

**Search content:** `grep_search` against the vault path.

**Read a note:** `view_file` with the absolute WSL path.

**Create a note:** `write_to_file` → `/mnt/c/Users/USER/Desktop/personal/AI Inbox/<filename>.md`
