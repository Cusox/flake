#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
encrypted_dir="$repo_root/secrets/vps/encrypted"
decrypted_dir="$repo_root/secrets/vps/decrypted"

if ! command -v sops >/dev/null 2>&1; then
    echo "error: sops is not installed or not in PATH" >&2
    exit 1
fi

if [ ! -d "$encrypted_dir" ]; then
    echo "error: encrypted directory not found: $encrypted_dir" >&2
    exit 1
fi

mkdir -p "$decrypted_dir"

found=0

for encrypted_file in "$encrypted_dir"/*.nix; do
    if [ ! -e "$encrypted_file" ]; then
        break
    fi

    found=1

    file_name="$(basename "$encrypted_file")"
    decrypted_file="$decrypted_dir/$file_name"
    tmp_file="$decrypted_file.tmp"

    echo "decrypting $encrypted_file -> $decrypted_file"

    sops -d "$encrypted_file" >"$tmp_file"
    mv "$tmp_file" "$decrypted_file"
    chmod 600 "$decrypted_file"
done

if [ "$found" -eq 0 ]; then
    echo "no encrypted .nix files found in $encrypted_dir"
fi

echo
echo "Please input commands manually:"
echo "export HOST_CONFIG='$decrypted_dir'"
