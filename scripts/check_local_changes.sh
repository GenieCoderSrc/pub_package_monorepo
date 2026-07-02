#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

PACKAGES_DIR="packages"

echo "Checking packages for local changes..."
echo

has_changes=false

find "$PACKAGES_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    if [ -d "$dir/.git" ]; then
        status=$(git -C "$dir" status --porcelain)

        if [ -n "$status" ]; then
            has_changes=true
            echo "===== $(basename "$dir") ====="
            echo "$status"
            echo
        fi
    fi
done

echo "Done."