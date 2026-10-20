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

# Cache mermaid.min.js locally for offline diagram rendering if not already present
if [ ! -f "$target_dir/mermaid.min.js" ]; then
    for local_mermaid in \
        "/usr/share/javascript/mermaid/mermaid.min.js" \
        "/usr/lib/claude-desktop/resources/ion-dist/_frame-rt/_runtime/mermaid-11.17.2.min.js"; do
        if [ -f "$local_mermaid" ]; then
            cp "$local_mermaid" "$target_dir/mermaid.min.js"
            echo "mermaid -> $target_dir/mermaid.min.js (copied from $local_mermaid)"
            break
        fi
    done
fi

if [ ! -f "$target_dir/mermaid.min.js" ] && command -v curl >/dev/null 2>&1; then
    if curl -fsSL "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js" -o "$target_dir/mermaid.min.js"; then
        echo "mermaid -> $target_dir/mermaid.min.js (downloaded from jsDelivr)"
    fi
fi

if pkill -f org.gnome.NautilusPreviewer 2>/dev/null; then
    echo "restarted org.gnome.NautilusPreviewer"
fi
