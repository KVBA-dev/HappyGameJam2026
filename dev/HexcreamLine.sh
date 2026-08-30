#!/bin/sh
printf '\033c\033]0;%s\a' godot_tips_n_tricks
base_path="$(dirname "$(realpath "$0")")"
"$base_path/HexcreamLine.x86_64" "$@"
