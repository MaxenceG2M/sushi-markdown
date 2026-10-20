#!/usr/bin/env bash
# Symlink sushi-markdown into ~/.local/share/sushi and restart GNOME Sushi.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
target_dir="${XDG_DATA_HOME:-$HOME/.local/share}/sushi"

chmod +x "$here/render_markdown.py"
mkdir -p "$target_dir/viewers"

ln -sfn "$here/render_markdown.py" "$target_dir/render_markdown.py"
ln -sfn "$here/viewers/markdown.js" "$target_dir/viewers/markdown.js"

echo "viewer -> $target_dir/viewers/markdown.js"
echo "helper -> $target_dir/render_markdown.py"

if pkill -f org.gnome.NautilusPreviewer 2>/dev/null; then
    echo "restarted org.gnome.NautilusPreviewer"
fi
