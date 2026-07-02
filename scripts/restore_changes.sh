#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

PACKAGES_DIR="packages"

MODE="${1:-all}"
#MODE="${1:-target}"
TARGET_FILE="${2:-.github/workflows/notify-mono.yml}"

echo "Mode: $MODE"
echo

find "$PACKAGES_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    [ -d "$dir/.git" ] || continue

    repo=$(basename "$dir")

    case "$MODE" in
        target)
            if git -C "$dir" ls-files --error-unmatch "$TARGET_FILE" >/dev/null 2>&1; then
                echo "Restoring '$TARGET_FILE' in $repo..."
                git -C "$dir" restore "$TARGET_FILE"
            else
                echo "Skipping $repo (file not tracked)"
            fi
            ;;

        all)
            echo "Restoring all tracked changes in $repo..."
            git -C "$dir" restore .
            ;;

        *)
            echo "Unknown mode: $MODE"
            echo
            echo "Usage:"
            echo "  $0 target [file]"
            echo "  $0 all"
            exit 1
            ;;
    esac
done

echo
echo "Done."