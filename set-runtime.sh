#!/bin/sh

set -x

error() {
  echo "$@"
  exit 1
}

libdir="$1"
bindir="$2"
[ -n "$libdir" ] || error "Library output directory is required."
[ -n "$bindir" ] || error "Binary base directory is required."
shift 2

if ! [ -f "$libdir/ld.so" ]; then
  mkdir -p "$libdir"
  cp -Ppv /usr/lib/sdk/swift/lib/swift/linux/*.so /usr/lib/sdk/swift/flatpak/*.so* \
    "$libdir"
  rm -rf "$libdir/*icu*.55.1"
fi

for exec in "$@"; do
  /usr/lib/sdk/swift/flatpak/patchelf --set-interpreter "$libdir/ld.so" "$bindir/$exec"
done
