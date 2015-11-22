#!/bin/bash
set -e

(
# find all bash files and run `shellcheck`
find . -name '*.sh' -exec sh -c '
	shellcheck "$1" && echo "[PASS] $1"
  ' sh {} \;
) || true
