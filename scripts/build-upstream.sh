#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source=${1:?Usage: sh scripts/build-upstream.sh PATCHED_SOURCE TARGET}
target=${2:?Target: dashboard, status-page, server, workflows, private-location, probe, db-migrate, tinybird-deploy}
source=$(CDPATH= cd -- "$source" && pwd)
platform=${PLATFORM:-linux/amd64}
tag="openstatus-railway-${target}:local"

case "$target" in
  dashboard|status-page|server|workflows|private-location)
    docker build --platform "$platform" -f "$source/apps/$target/Dockerfile" -t "$tag-upstream" "$source"
    docker build --platform "$platform" --build-arg "OPENSTATUS_IMAGE=$tag-upstream" -t "$tag" "$root/$target"
    ;;
  probe)
    docker build --platform "$platform" -f "$source/apps/checker/private-location.Dockerfile" -t "$tag" "$source/apps/checker"
    ;;
  db-migrate)
    docker build --platform "$platform" -f "$source/packages/db/Dockerfile" -t "$tag" "$source"
    ;;
  tinybird-deploy)
    docker build --platform "$platform" --build-context "schema=$source/packages/tinybird" -t "$tag" "$root/tinybird-deploy"
    ;;
  *)
    echo "Unknown target: $target" >&2
    exit 1
    ;;
esac
printf 'Built %s locally. No image was pushed.\n' "$tag"
