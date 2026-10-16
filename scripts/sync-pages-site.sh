#!/usr/bin/env bash
# Copy markdown (and data) into docs/site/ for Jekyll — run in CI before build.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$ROOT/docs/site"
rm -rf "$SITE"
mkdir -p "$SITE"

copy_md_tree() {
  local src="$1"
  local dest="$2"
  [ -d "$src" ] || return 0
  mkdir -p "$dest"
  rsync -a --include='*/' --include='*.md' --exclude='*' "$src/" "$dest/"
}

for f in README.md NAVIGATION.md FAQ.md; do
  [ -f "$ROOT/$f" ] && cp "$ROOT/$f" "$SITE/"
done

copy_md_tree "$ROOT/resources" "$SITE/resources"
copy_md_tree "$ROOT/programs" "$SITE/programs"
copy_md_tree "$ROOT/hackathons" "$SITE/hackathons"
copy_md_tree "$ROOT/organizations" "$SITE/organizations"
copy_md_tree "$ROOT/templates" "$SITE/templates"

[ -f "$ROOT/docs/WHATS-NOT-LISTED.md" ] && mkdir -p "$SITE/docs" && cp "$ROOT/docs/WHATS-NOT-LISTED.md" "$SITE/docs/"

mkdir -p "$SITE/data"
for f in programs.json hackathon-platforms.json deadlines.json; do
  [ -f "$ROOT/data/$f" ] && cp "$ROOT/data/$f" "$SITE/data/"
done
[ -f "$ROOT/data/deadlines.ics" ] && cp "$ROOT/data/deadlines.ics" "$SITE/data/"

echo "Synced $(find "$SITE" -type f | wc -l) files into docs/site/"
