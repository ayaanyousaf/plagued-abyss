#!/bin/sh
printf '\033c\033]0;%s\a' Plagued-Abyss
base_path="$(dirname "$(realpath "$0")")"
"$base_path/AbyssalOutbreak.x86_64" "$@"
