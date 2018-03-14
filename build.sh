#!/bin/bash

base="`dirname "$0"`"

root="$base/root"

which="$1"
action="$2"
shift 2

case "$which" in
sdk) file="$base/org.freedesktop.Sdk.Extension.swift.json"; root="$base/root" ;;
test) file="$base/org.freedesktop.Sdk.Extension.swift.test.json"; root="$base/root.test" ;;
example) file="$base/org.freedesktop.Sdk.Extension.swift.example.json"; root="$base/root.ex" ;;
clear-cache) rm -rf "$base/.flatpak-builder/build"; exit ;;
clear-all)
  rm -rf "$base/root" "$base/root.test" "$base/root.ex" "$base/.flatpak-builder" \
         "$base/repo"
  exit 0 ;;
*) echo 'Invalid argument.'; exit 1 ;;
esac

case "$action" in
build) args=--force-clean ;;
run) args=--run ;;
repo) args="--repo=$base/repo --force-clean" ;;
update) flatpak --user update `basename "$file" .json`; exit ;;
*) echo 'Invalid argument.'; exit 1 ;;
esac

set -x
flatpak-builder $args "$root" "$file" "$@"
