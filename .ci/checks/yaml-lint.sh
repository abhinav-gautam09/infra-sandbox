#!/bin/sh
set -eu

yamllint -f parsable --no-warnings -c .yamllint.yml .

changed=$(for f in $ALL_CHANGED; do
  case "$f" in *.yml|*.yaml) [ -f "$f" ] && echo "$f" ;; esac
done)
[ -n "$changed" ] || exit 0

echo "Checking duplicate keys in changed files"
echo "$changed" | xargs yamllint -f parsable --no-warnings -d "{extends: .yamllint.yml, rules: {key-duplicates: enable}}"
