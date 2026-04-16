#!/bin/bash
# Package a skill folder into a .skill file (zip archive).
# Usage: ./scripts/package.sh <skill-name>
# Example: ./scripts/package.sh hunch  →  dist/hunch.skill

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <skill-name>"
  exit 1
fi

SKILL="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/$SKILL"
OUT_DIR="$ROOT/dist"
OUT="$OUT_DIR/$SKILL.skill"

if [ ! -d "$SRC" ]; then
  echo "No such skill folder: $SRC"
  exit 1
fi

if [ ! -f "$SRC/SKILL.md" ]; then
  echo "Missing SKILL.md in $SRC"
  exit 1
fi

mkdir -p "$OUT_DIR"
rm -f "$OUT"

cd "$ROOT"
zip -r "$OUT" "$SKILL" -x "*.DS_Store" >/dev/null

echo "Built $OUT"
