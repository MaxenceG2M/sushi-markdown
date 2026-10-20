#!/usr/bin/env bash
# Remove sushi-markdown symlinks from ~/.local/share/sushi and restart GNOME Sushi.
set -euo pipefail

target_dir="${XDG_DATA_HOME:-$HOME/.local/share}/sushi"

rm -f "$target_dir/viewers/markdown.js" "$target_dir/render_markdown.py"
rmdir --ignore-fail-on-non-empty "$target_dir/viewers" "$target_dir" 2>/dev/null || true

echo "removed sushi-markdown from $target_dir"

if pkill -f org.gnome.NautilusPreviewer 2>/dev/null; then
    echo "restarted org.gnome.NautilusPreviewer"
fi
