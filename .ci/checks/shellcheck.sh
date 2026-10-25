#!/bin/sh
set -eu

scripts=$(for f in $ALL_CHANGED; do
  case "$f" in *.sh) [ -f "$f" ] && echo "$f" ;; esac
done)
if [ -z "$scripts" ]; then
  echo "No shell scripts changed"
  exit 0
fi
echo "$scripts" | xargs shellcheck
