#!/usr/bin/env bash
# Install the token-efficient rules so they apply by default.
#
#   ./scripts/install-token-efficient.sh --global            # ~/.claude/CLAUDE.md (all projects, this machine)
#   ./scripts/install-token-efficient.sh --project /path     # <path>/CLAUDE.md (one project)
#   ./scripts/install-token-efficient.sh --global --project . # both
#
# Idempotent: re-running replaces the managed block, it never duplicates it.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.claude/rules/token-efficient.md"
BEGIN="<!-- BEGIN token-efficient -->"
END="<!-- END token-efficient -->"

[ -f "$SRC" ] || { echo "missing rules file: $SRC" >&2; exit 1; }

write_block() { # $1 = target CLAUDE.md, $2 = block body file
  local target="$1" body="$2" tmp
  tmp="$(mktemp)"
  mkdir -p "$(dirname "$target")"
  if [ -f "$target" ] && grep -qF "$BEGIN" "$target"; then
    awk -v b="$BEGIN" -v e="$END" 'index($0,b){s=1} !s{print} index($0,e){s=0}' "$target" > "$tmp"
  elif [ -f "$target" ]; then
    cat "$target" > "$tmp"
    printf '\n' >> "$tmp"
  fi
  { echo "$BEGIN"; cat "$body"; echo "$END"; } >> "$tmp"
  mv "$tmp" "$target"
  echo "updated $target"
}

do_global=0 project=""
while [ $# -gt 0 ]; do
  case "$1" in
    --global) do_global=1 ;;
    --project) project="${2:?--project needs a path}"; shift ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
  shift
done
[ "$do_global" = 1 ] || [ -n "$project" ] || { echo "nothing to do: pass --global and/or --project PATH" >&2; exit 1; }

if [ "$do_global" = 1 ]; then
  write_block "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md" "$SRC"
fi

if [ -n "$project" ]; then
  dest="$project/.claude/rules/token-efficient.md"
  mkdir -p "$(dirname "$dest")"
  [ "$(cd "$(dirname "$SRC")" && pwd)" = "$(cd "$(dirname "$dest")" && pwd)" ] || cp "$SRC" "$dest"
  ref="$(mktemp)"
  printf '@.claude/rules/token-efficient.md\n' > "$ref"
  write_block "$project/CLAUDE.md" "$ref"
  rm -f "$ref"
fi
