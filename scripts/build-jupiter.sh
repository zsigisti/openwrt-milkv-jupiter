#!/usr/bin/env bash
#
# Build OpenWrt for the Milk-V Jupiter (SpacemiT K1) inside a Debian container.
#
# Usage:
#   ./scripts/build-jupiter.sh
#
# Produces (under bin/targets/spacemit/):
#   openwrt-spacemit-k1-sbc-Milkv-Jupiter-squashfs-sdcard.img.gz   <- recommended
#   openwrt-spacemit-k1-sbc-Milkv-Jupiter-ext4-sdcard.img.gz
#
# Requirements: docker (or set CONTAINER=podman), ~25 GB free disk, a few CPU cores.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTAINER="${CONTAINER:-docker}"
IMAGE="${IMAGE:-owrt-jupiter-builder}"
JOBS="${JOBS:-$(nproc)}"

cd "$REPO_ROOT"

echo ">> Building container image ($IMAGE)..."
"$CONTAINER" build -t "$IMAGE" "$REPO_ROOT/docker"

echo ">> Seeding .config for the Milk-V Jupiter target..."
cp -f configs/jupiter.config .config

# Everything below runs inside the container, as the invoking user so OpenWrt's
# "do not build as root" guard is satisfied and output files stay user-owned.
echo ">> Building OpenWrt (this takes a while)..."
"$CONTAINER" run --rm \
  -v "$REPO_ROOT":/src -w /src \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp/bh \
  "$IMAGE" \
  bash -c '
    set -e
    mkdir -p /tmp/bh
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    make defconfig
    make download -j8
    make -j'"$JOBS"'
  '

echo ">> Done. Images:"
ls -lh bin/targets/spacemit/*Milkv-Jupiter* 2>/dev/null || \
  echo "   (no images found - check the build output above)"
