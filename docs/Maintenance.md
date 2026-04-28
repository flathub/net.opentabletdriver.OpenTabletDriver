# Maintenance Guide

## Regenerating NuGet Sources

Every PR that changes the OpenTabletDriver version or NuGet dependencies **must** regenerate the source files. The Flatpak build is fully offline, which is a Flathub requirement, so all NuGet packages are pre-declared in `sources/linux-x64.json` and `sources/linux-arm64.json`.

```bash
./scripts/generate-sources.sh
```

Options:

```
--tag TAG        Override the tag (default: read from manifest)
--latest         Use the latest GitHub release tag
--runtime VER    Override freedesktop runtime version (default: from manifest)
--keep-temp      Don't delete temporary files
-h, --help       Show help
```

## Updating the Version

Refer to [`.github/workflows/update.yml`](../.github/workflows/update.yml) for the automated update process. It can be triggered manually via `workflow_dispatch`, which will:

1. Fetch the latest release tag from the OpenTabletDriver repo
2. Regenerate `sources/linux-x64.json` and `sources/linux-arm64.json`
3. Update the `tag:` field in the manifest
4. Open a PR to `master`

To update manually, change the `tag:` under the `opentabletdriver` git source in `net.opentabletdriver.OpenTabletDriver.yaml`, then run `./scripts/generate-sources.sh`.

> **Note:** The workflow's `FREEDESKTOP_VERSION` env var must match the manifest's `runtime-version`. Update it if you bump the runtime.

## Running the Linter

**Run the linter before every PR.** Flathub will reject submissions that fail lint checks.

```bash
# Lint the manifest
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest net.opentabletdriver.OpenTabletDriver.yaml

# Lint the build repo (after building with --repo=repo)
flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo repo
```

Install with `flatpak install flathub org.flatpak.Builder` if not present.

For the full list of checks and exception process, see the [Flathub Linter documentation](https://docs.flathub.org/docs/for-app-authors/linter).
