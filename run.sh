#!/bin/bash

FLAGS=()

if [[ $XDG_SESSION_TYPE == "wayland" ]]
then
  if [ -c /dev/nvidia0 ]
  then
    FLAGS+=("--disable-gpu-sandbox")
  fi
fi

env TMPDIR="$XDG_RUNTIME_DIR/app/${FLATPAK_ID:-dev.k8slens.openlens}" zypak-wrapper /app/OpenLens/open-lens "${FLAGS[@]}" "$@"
