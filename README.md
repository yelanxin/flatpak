# OxiTide Flatpak repository

Self-hosted Flatpak remote for [OxiTide](https://github.com/yelanxin/OxiTide),
served via GitHub Pages (custom domain: `flatpak.oxitide.com`).

The app is packaged as **extra-data**: this repo only holds signed OSTree
metadata (a few MB); the actual binary is downloaded from the official
GitHub release at install time. The GNOME runtime comes from Flathub
(`RuntimeRepo` in the flatpakref).

## Install (users)

```bash
flatpak install --user https://flatpak.oxitide.com/oxitide.flatpakref
```

Updates arrive through normal `flatpak update`.

## Layout

| Path | What |
|---|---|
| `manifest/` | Flatpak manifest + desktop/metainfo/icons (synced from OxiTide-src `flatpak/flathub/`, minus `flathub.json`) |
| `templates/` | `.flatpakrepo` / `.flatpakref` templates (`@BASEURL@`, `@GPGKEY@` placeholders) |
| `build-repo.sh` | Builds `repo/` (signed OSTree), regenerates the entry-point files |
| `repo/` | The published OSTree repository (generated, committed) |
| `oxitide.gpg` | Exported public signing key (generated) |

## Publishing a release

1. Update `url` / `sha256` / `size` of the extra-data source in
   `manifest/io.github.yelanxin.OxiTide.yml` (+ metainfo release entry).
2. `OXITIDE_FLATPAK_GPG=<keyid> ./build-repo.sh`
3. Commit and push everything; GitHub Pages redeploys automatically.

## One-time setup

1. Generate the signing key (keep the private key safe — losing it means
   every user must re-add the remote):
   `gpg --quick-generate-key "OxiTide Flatpak Repo <yelanxin@gmail.com>" ed25519 sign never`
2. Run `build-repo.sh` (see header) and push.
3. Once `oxitide.com` is registered: repo Settings → Pages → Custom domain
   `flatpak.oxitide.com`, and add a Cloudflare DNS record
   `CNAME flatpak → yelanxin.github.io` (DNS-only until the cert is issued).
   Until then, build with
   `FLATPAK_BASE_URL=https://yelanxin.github.io/flatpak` instead.
