#!/usr/bin/env bash

set -euo pipefail

#TARGET_BRANCH="detached"
TARGET_BRANCH="main"

ROOT="$(git rev-parse --show-toplevel)"

echo "Pulling monorepo..."
git -C "$ROOT" pull

echo

find "$ROOT/packages" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    [ -d "$dir/.git" ] || continue

    repo=$(basename "$dir")

    if ! git -C "$dir" diff --quiet ||
       ! git -C "$dir" diff --cached --quiet; then
        echo "Skipping $repo (has local changes)"
        continue
    fi

    echo "Fetching $repo..."
    git -C "$dir" fetch origin

    if git -C "$dir" show-ref --verify --quiet "refs/remotes/origin/$TARGET_BRANCH"; then
        BRANCH="$TARGET_BRANCH"
    else
        BRANCH=$(git -C "$dir" branch --show-current)

        if [ -z "$BRANCH" ]; then
            echo "Skipping $repo (detached HEAD and '$TARGET_BRANCH' not found)"
            echo
            continue
        fi
    fi

    echo "Pulling $repo from '$BRANCH'..."

    git -C "$dir" pull origin "$BRANCH"

    echo
done

echo "Done."