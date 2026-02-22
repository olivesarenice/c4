---
name: python-project
description: Conventions and tooling for Python projects using uv
---

# Python Project Skill

## Environment Management
- Always use `uv` for virtual environments and package management (NOT pip, NOT poetry).
- Init: `uv init .`
- Add dep: `uv add <package>`
- Run: `uv run python <script.py>`

## Project Structure
```
project/
├── src/<package>/
│   └── __init__.py
├── tests/
├── pyproject.toml     ← uv-managed
├── .python-version    ← pin Python version
└── README.md
```

## Code Style
- Type hints on all function signatures.
- Use `ruff` for linting and formatting (NOT black, NOT flake8).
- Run: `uv run ruff check . && uv run ruff format .`

## Testing
- Use `pytest`. Run: `uv run pytest`
- Test files: `tests/test_<module>.py`

## Common Patterns
- Config: use `pydantic-settings` with `.env` files, never hardcode secrets.
- CLI: use `typer`.
- HTTP: use `httpx` (async-first), not `requests`.
- Data: use `polars`, not `pandas` unless forced.
