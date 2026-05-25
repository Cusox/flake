#!/usr/bin/env bash
set -euo pipefail

host="${1:?usage: $0 <vps-host-name>}"

root="$(git rev-parse --show-toplevel)"

encrypted_file="$root/config/vps/encrypted/${host}.nix"

decrypted_dir="$root/config/vps/decrypted"
decrypted_file="$decrypted_dir/${host}.nix"

if [ ! -f "$encrypted_file" ]; then
    echo "missing encrypted config: $encrypted_file" >&2
    exit 1
fi

mkdir -p "$decrypted_dir"

sops -d "$encrypted_file" >"$decrypted_file"

VPS_BOOTSTRAP_HOST="$host" \
    VPS_BOOTSTRAP_CONFIG="$decrypted_file" \
    nix build --impure "$root#vps-bootstrap-image"

echo
echo "built image:"
echo "  result/main.raw"
