#!/bin/bash

base="$(realpath "$(dirname "$0")")"

root="$base/root"

which="$1"
action="$2"
shift 2

case "$which" in
sdk) file="$base/org.freedesktop.Sdk.Extension.swift4.json"; root="$base/root" ;;
live) file="$base/org.freedesktop.Sdk.Extension.swift4.live.json"; root="$base/root.live" ;;
example) file="$base/org.freedesktop.Sdk.Extension.swift4.example.json"; root="$base/root.ex" ;;
remote-add) flatpak --user remote-add --no-gpg-verify swift-local "file://$base/repo"; exit ;;
remote-delete) flatpak remote-delete swift-local; exit ;;
clear-cache) rm -rf "$base/.flatpak-builder/build"; exit ;;
clear-all)
  rm -rf "$base/root" "$base/root.live" "$base/root.ex" "$base/.flatpak-builder" \
         "$base/repo"
  exit 0 ;;
*) echo 'Invalid argument.'; exit 1 ;;
esac

case "$action" in
build) args=--force-clean ;;
run) args=--run ;;
repo) args="--repo=$base/repo --force-clean" ;;
install) flatpak --user install swift-local `basename "$file" .json`; exit ;;
uninstall) flatpak --user uninstall `basename "$file" .json`; exit ;;
update) flatpak --user update `basename "$file" .json`; exit ;;
*) echo 'Invalid argument.'; exit 1 ;;
esac

set -x
flatpak-builder $args "$root" "$file" "$@"
