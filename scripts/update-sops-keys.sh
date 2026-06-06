#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! command -v sops >/dev/null 2>&1; then
    echo "error: sops is not installed or not in PATH" >&2
    exit 1
fi

files=(
    "secrets/system.yaml"
    "secrets/home.yaml"
    "secrets/ssh/config.yaml"
)

if [ -d "secrets/vps/encrypted" ]; then
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find secrets/vps/encrypted -type f -name '*.nix' -print0)
fi

if [ -d "secrets/docker" ]; then
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find secrets/docker -type f -name '.env' -print0)
fi

for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "skip missing: $file" >&2
        continue
    fi

    echo "updating sops keys: $file"
    sops updatekeys --yes "$file"
done
