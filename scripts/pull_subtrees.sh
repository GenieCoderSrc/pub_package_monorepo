#!/usr/bin/env bash
##!/bin/bash

set -e

ROOT=$(git rev-parse --show-toplevel)

git -C "$ROOT" pull

find "$ROOT/packages" -mindepth 1 -maxdepth 1 -type d | while read dir
do
    [ -d "$dir/.git" ] || continue

    if ! git -C "$dir" diff --quiet ||
       ! git -C "$dir" diff --cached --quiet; then
        echo "Skipping $(basename "$dir") (has local changes)"
        continue
    fi

    echo "Pulling $(basename "$dir")..."
    git -C "$dir" pull
done