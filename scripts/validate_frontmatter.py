#!/usr/bin/env python3
"""Validate YAML frontmatter on agent and skill markdown files.

Required fields:
  agents/*.md   name (str), description (str), tools (list[str]), model (str)
  skills/*.md   name (str), description (str)

README.md inside those directories is excluded (those are navigation files,
not agents or skills).

Exits non-zero on any violation. Prints a per-file diagnostic.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
FRONTMATTER_RE = re.compile(r"\A---\s*\n(.*?)\n---\s*\n", re.DOTALL)

REQUIRED_FIELDS: dict[str, dict[str, type | tuple[type, ...]]] = {
    "agents": {
        "name": str,
        "description": str,
        "tools": list,
        "model": str,
    },
    "skills": {
        "name": str,
        "description": str,
    },
}


def validate(directory: str, schema: dict[str, type | tuple[type, ...]]) -> list[str]:
    errors: list[str] = []
    dir_path = REPO_ROOT / directory
    for md in sorted(dir_path.glob("*.md")):
        if md.name == "README.md":
            continue
        rel = md.relative_to(REPO_ROOT).as_posix()
        text = md.read_text(encoding="utf-8")

        match = FRONTMATTER_RE.match(text)
        if not match:
            errors.append(f"{rel}: missing frontmatter block")
            continue

        try:
            data = yaml.safe_load(match.group(1)) or {}
        except yaml.YAMLError as exc:
            errors.append(f"{rel}: invalid YAML ({exc})")
            continue

        if not isinstance(data, dict):
            errors.append(f"{rel}: frontmatter must be a YAML mapping")
            continue

        for field, expected_type in schema.items():
            if field not in data:
                errors.append(f"{rel}: missing required field '{field}'")
                continue
            if not isinstance(data[field], expected_type):
                got = type(data[field]).__name__
                want = (
                    expected_type.__name__
                    if isinstance(expected_type, type)
                    else " | ".join(t.__name__ for t in expected_type)
                )
                errors.append(
                    f"{rel}: field '{field}' has wrong type (got {got}, want {want})"
                )
    return errors


def main() -> int:
    all_errors: list[str] = []
    for directory, schema in REQUIRED_FIELDS.items():
        all_errors.extend(validate(directory, schema))

    if all_errors:
        print("Frontmatter validation failed:", file=sys.stderr)
        for err in all_errors:
            print(f"  {err}", file=sys.stderr)
        return 1

    print("Frontmatter validation: all files OK.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
