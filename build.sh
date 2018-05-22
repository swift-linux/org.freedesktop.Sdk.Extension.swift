#!/bin/bash

set -e

base="$(realpath "$(dirname "$0")")"

root="$base/root"
repo="$base/repo"

which="$1"
action="$2"

GPG_KEY="${GPG_KEY:-3D0FA8117F28EEE7FEAA305D6B2F86B16910DDA0}"

run() {
  (set -x; "$@")
}

case "$which" in
sdk) file="$base/org.freedesktop.Sdk.Extension.swift4.yaml"; root="$base/root" ;;
live) file="$base/org.freedesktop.Sdk.Extension.swift4.live.yaml"; root="$base/root.live" ;;
example) file="$base/org.freedesktop.Sdk.Extension.swift4.example.yaml"; root="$base/root.ex" ;;
remote-add) run flatpak --user remote-add --no-gpg-verify swift-local "file://$base/repo"; exit ;;
remote-delete) run flatpak remote-delete swift-local; exit ;;
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
pub) args="--repo=$base/pub --force-clean" ;;
install) run flatpak --user install swift-local `basename "$file" .yaml`; exit ;;
uninstall) run flatpak --user uninstall `basename "$file" .yaml`; exit ;;
update) run flatpak --user update `basename "$file" .yaml`; exit ;;
*) echo 'Invalid argument.'; exit 1 ;;
esac

shift 2
run flatpak-builder $args "$root" "$file" "$@"

if [ "$action" = "pub" ]; then
  run flatpak build-sign "$base/pub" --gpg-sign="$GPG_KEY"
  run flatpak build-update-repo "$base/pub" --gpg-sign="$GPG_KEY"

  echo "[Flatpak Repo]" > "$base/pub/swift.flatpakrepo"
  echo "Title=Swift" >> "$base/pub/swift.flatpakrepo"
  echo "Url=https://swift-flatpak.refi64.com" >> "$base/pub/swift.flatpakrepo"
  echo -n "GPGKey=" >> "$base/pub/swift.flatpakrepo"
  gpg --export="$GPG_KEY" | base64 --wrap=0 >> "$base/pub/swift.flatpakrepo"
fi
