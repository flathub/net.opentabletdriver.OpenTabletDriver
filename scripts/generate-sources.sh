#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "$repo_root" == /run/* ]]; then
  repo_root="/${repo_root#/run/host/}"
fi
manifest="$repo_root/net.opentabletdriver.OpenTabletDriver.yaml"

usage() {
  cat <<'EOF'
Usage: scripts/generate-sources.sh [options]

Generate:
  - sources/linux-x64.json
  - sources/linux-arm64.json

Options:
  --tag <tag>       Override the OpenTabletDriver tag from the manifest
  --latest          Use the latest GitHub release tag
  --runtime <ver>   Override manifest runtime-version, e.g. 25.08
  --keep-temp       Keep the temporary working directory
  -h, --help        Show this help text
EOF
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

extract_runtime_version() {
  awk -F'"' '/^runtime-version:/ { print $2; exit }' "$manifest"
}

extract_otd_tag() {
  awk '
    /- name: opentabletdriver/ { in_module=1; next }
    in_module && /^[[:space:]]+- type: git$/ { in_git=1; next }
    in_module && in_git && /^[[:space:]]+tag:/ { print $2; exit }
  ' "$manifest"
}

latest_otd_tag() {
  curl -fsSL https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest \
    | python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])'
}

check_flatpak_ref() {
  local ref="$1"
  if ! flatpak info "$ref" >/dev/null 2>&1; then
    echo "Missing Flatpak ref: $ref" >&2
    echo "Install it first, for example:" >&2
    echo "  flatpak install flathub $ref -y" >&2
    exit 1
  fi
}

write_json_from_packages() {
  local packages_dir="$1"
  local output_json="$2"

  python3 - "$packages_dir" "$output_json" <<'PY'
from pathlib import Path
import base64
import binascii
import json
import sys

packages_dir = Path(sys.argv[1])
output_json = Path(sys.argv[2])
sources = []

for path in packages_dir.glob("**/*.nupkg.sha512"):
    name = path.parent.parent.name
    version = path.parent.name
    filename = f"{name}.{version}.nupkg"
    url = f"https://api.nuget.org/v3-flatcontainer/{name}/{version}/{filename}"
    sha512 = binascii.hexlify(base64.b64decode(path.read_text().strip())).decode("ascii")
    sources.append({
        "type": "file",
        "url": url,
        "sha512": sha512,
        "dest": "nuget-sources",
        "dest-filename": filename,
    })

sources.sort(key=lambda item: item["dest-filename"])
output_json.write_text(json.dumps(sources, indent=4) + "\n")
PY
}

generate_json() {
  local runtime_arch="$1"
  local output_json="$repo_root/sources/$runtime_arch.json"
  local temp_output="$workdir/$runtime_arch.json"
  local packages_dir="$workdir/packages-$runtime_arch"

  rm -rf "$packages_dir"
  mkdir -p "$packages_dir"

  echo "Generating $runtime_arch..."
  HOME="$workdir/home" \
  XDG_CACHE_HOME="$workdir/cache" \
  flatpak run \
    --env=DOTNET_CLI_TELEMETRY_OPTOUT=true \
    --env=DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true \
    --command=sh \
    --runtime="org.freedesktop.Sdk//$freedesktop_version" \
    --share=network \
    --filesystem="$workdir" \
    "org.freedesktop.Sdk.Extension.dotnet8//$freedesktop_version" \
    -c '
      set -euo pipefail
      work=/tmp/otdsrc
      rm -rf "$work"
      mkdir -p "$work"
      tar -xzf "$1/archive.tar.gz" -C "$work"
      cd "$work"/OpenTabletDriver-*
      export PATH="$PATH:/usr/lib/sdk/dotnet8/bin"
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/sdk/dotnet8/lib"
      exec dotnet restore --packages "$1/packages-$2" OpenTabletDriver.Linux.slnf -r "$2" -p:PublishSingleFile=true
    ' \
    sh "$workdir" "$runtime_arch"

  write_json_from_packages "$packages_dir" "$temp_output"

  if [[ ! -s "$temp_output" ]] || [[ "$(tr -d '\n\r\t ' < "$temp_output")" == "[]" ]]; then
    echo "Generation failed for $runtime_arch: produced an empty sources file." >&2
    echo "Keeping the existing $output_json unchanged." >&2
    return 1
  fi

  mv "$temp_output" "$output_json"
}

require_cmd awk
require_cmd curl
require_cmd flatpak
require_cmd python3
require_cmd tar

tag_override=""
latest_tag=0
runtime_override=""
keep_temp=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      tag_override="${2:-}"
      shift 2
      ;;
    --latest)
      latest_tag=1
      shift
      ;;
    --runtime)
      runtime_override="${2:-}"
      shift 2
      ;;
    --keep-temp)
      keep_temp=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

freedesktop_version="${runtime_override:-$(extract_runtime_version)}"
if [[ -z "$freedesktop_version" ]]; then
  echo "Failed to read runtime-version from $manifest" >&2
  exit 1
fi

if [[ "$latest_tag" -eq 1 ]]; then
  otd_tag="$(latest_otd_tag)"
elif [[ -n "$tag_override" ]]; then
  otd_tag="$tag_override"
else
  otd_tag="$(extract_otd_tag)"
fi

if [[ -z "$otd_tag" ]]; then
  echo "Failed to determine OpenTabletDriver tag" >&2
  exit 1
fi

check_flatpak_ref "org.freedesktop.Platform//$freedesktop_version"
check_flatpak_ref "org.freedesktop.Sdk//$freedesktop_version"
check_flatpak_ref "org.freedesktop.Sdk.Extension.dotnet8//$freedesktop_version"

mkdir -p "$repo_root/build-dir"
workdir="$repo_root/build-dir/otd-sources-gen"
rm -rf "$workdir"
mkdir -p "$workdir/home" "$workdir/cache"

cleanup() {
  if [[ "$keep_temp" -eq 1 ]]; then
    echo "Keeping temporary directory: $workdir"
  else
    rm -rf "$workdir"
  fi
}
trap cleanup EXIT

echo "Using OpenTabletDriver tag: $otd_tag"
echo "Using Freedesktop runtime: $freedesktop_version"
echo "Downloading source archive..."
curl -fL "https://github.com/OpenTabletDriver/OpenTabletDriver/archive/refs/tags/${otd_tag}.tar.gz" \
  -o "$workdir/archive.tar.gz"

generate_json "linux-x64"
generate_json "linux-arm64"

echo "Done."
echo "Updated:"
echo "  $repo_root/sources/linux-x64.json"
echo "  $repo_root/sources/linux-arm64.json"
