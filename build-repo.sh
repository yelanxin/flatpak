#!/usr/bin/env bash
# Build (or update) the OxiTide Flatpak repository into ./repo and
# regenerate the .flatpakrepo / .flatpakref entry points.
#
# Prerequisites (one-time):
#   - flatpak-builder, and the Flathub remote configured (for the GNOME SDK):
#       flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
#   - a dedicated GPG signing key:
#       gpg --quick-generate-key "OxiTide Flatpak Repo <yelanxin@gmail.com>" ed25519 sign never
#
# Usage:
#   OXITIDE_FLATPAK_GPG=<keyid> ./build-repo.sh
#   FLATPAK_BASE_URL=https://yelanxin.github.io/flatpak OXITIDE_FLATPAK_GPG=<keyid> ./build-repo.sh
#
# Then commit and push repo/, oxitide.gpg, oxitide.flatpakrepo, oxitide.flatpakref.
#
# Per release: bump url / sha256 / size of the extra-data source in
# manifest/io.github.yelanxin.OxiTide.yml (and the metainfo release entry),
# then re-run this script.
set -euo pipefail
cd "$(dirname "$0")"

KEYID="${OXITIDE_FLATPAK_GPG:?Set OXITIDE_FLATPAK_GPG to the repo signing GPG key id}"
BASE_URL="${FLATPAK_BASE_URL:-https://flatpak.oxitide.com}"

flatpak-builder --force-clean --default-branch=stable \
  --install-deps-from=flathub --user \
  --gpg-sign="$KEYID" --repo=repo \
  builddir manifest/io.github.yelanxin.OxiTide.yml

flatpak build-update-repo --generate-static-deltas --prune \
  --gpg-sign="$KEYID" repo

gpg --export "$KEYID" > oxitide.gpg
GPGKEY_B64="$(base64 -w0 oxitide.gpg)"
for f in oxitide.flatpakrepo oxitide.flatpakref; do
  sed -e "s|@BASEURL@|$BASE_URL|" -e "s|@GPGKEY@|$GPGKEY_B64|" \
    "templates/$f.in" > "$f"
done

echo
echo "Repo built and signed. Base URL: $BASE_URL"
echo "Publish: git add -A && git commit -m 'repo: <version>' && git push"
echo "Install (user): flatpak install --user $BASE_URL/oxitide.flatpakref"
