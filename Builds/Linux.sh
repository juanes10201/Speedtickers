#!/bin/sh
printf '\033c\033]0;%s\a' PlatformerGame
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Linux.x86_64" "$@"
