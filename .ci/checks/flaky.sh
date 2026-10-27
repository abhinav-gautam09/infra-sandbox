#!/bin/sh
set -eu

age=$(( $(date +%s) - $(git log -1 --format=%ct "$HEAD") ))
if [ "$age" -lt 60 ]; then
  echo "first run, ${age}s after the commit: failing on purpose"
  exit 1
fi

roll=$(( $(od -An -N2 -tu2 /dev/urandom) % 3 ))
echo "re-run, ${age}s after the commit: rolled $roll, passes only on 0"
[ "$roll" -eq 0 ]
