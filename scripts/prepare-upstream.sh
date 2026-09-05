#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
destination=${1:?Usage: sh scripts/prepare-upstream.sh NEW_DIRECTORY}
revision=48b5a2c4b17e2146a65b66f4f6f68c7cfe73ba8c

if [ -e "$destination" ]; then
  echo "Destination already exists: $destination" >&2
  exit 1
fi

git clone --no-checkout https://github.com/openstatusHQ/openstatus.git "$destination"
git -C "$destination" checkout --detach "$revision"
git -C "$destination" apply --check "$root/patches/openstatus.patch"
git -C "$destination" apply "$root/patches/openstatus.patch"
printf 'Patched OpenStatus source: %s\n' "$destination"
