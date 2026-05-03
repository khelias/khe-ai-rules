#!/usr/bin/env python3
"""Warn (not fail) if LAST_REVIEWED.md is more than 90 days stale.

The 90-day window matches the quarterly review cadence in
LAST_REVIEWED.md's checklist. This is a soft signal: it surfaces a
GitHub Actions warning but does not break the build.
"""
from __future__ import annotations

import re
import sys
from datetime import date
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
STALENESS_DAYS = 90


def main() -> int:
    review_file = REPO_ROOT / "LAST_REVIEWED.md"
    if not review_file.exists():
        print(f"::warning file=LAST_REVIEWED.md::file is missing")
        return 0

    text = review_file.read_text(encoding="utf-8")
    dates = re.findall(r"\|\s*(\d{4}-\d{2}-\d{2})\s*\|", text)
    if not dates:
        print("::warning file=LAST_REVIEWED.md::no dated rows found in the table")
        return 0

    most_recent = max(date.fromisoformat(d) for d in dates)
    age_days = (date.today() - most_recent).days

    if age_days > STALENESS_DAYS:
        print(
            f"::warning file=LAST_REVIEWED.md::last review was {age_days} days ago "
            f"({most_recent.isoformat()}); >{STALENESS_DAYS} days. Time for a quarterly review."
        )
    else:
        print(
            f"LAST_REVIEWED.md is {age_days} days old "
            f"(last review {most_recent.isoformat()}); within {STALENESS_DAYS}-day window."
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
