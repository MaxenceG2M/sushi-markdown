#!/usr/bin/env bash
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

echo "1. Testing render_markdown.py HTML generation..."
cat > "$tmpdir/sample.md" <<'EOF'
---
title: Sample Doc
author: Pat
---
# Heading One

> [!NOTE]
> Important callout box

- [x] Done item
- [ ] Todo item

See [Other](./other.md#details) and [Section](#heading-one).

```python
def greet():
    return 42
```
EOF

html_out=$(python3 "$here/render_markdown.py" "$tmpdir/sample.md" dark)

grep -q 'class="theme-dark"' <<<"$html_out"
grep -q '<details class="frontmatter">' <<<"$html_out"
grep -q 'markdown-alert-note' <<<"$html_out"
grep -q 'task-list-item-checkbox" checked disabled' <<<"$html_out"
grep -q 'window.__sushiScrollTo' <<<"$html_out"
grep -q 'sushi-md://back' <<<"$html_out"
echo "   OK: HTML output contains dark theme, frontmatter, alerts, task checkboxes, and JS bridge."

echo "2. Testing GJS Sushi MimeHandler & MarkdownRenderer..."
export XDG_DATA_HOME="$tmpdir/xdg_data"
mkdir -p "$XDG_DATA_HOME/sushi/viewers"
ln -s "$here/render_markdown.py" "$XDG_DATA_HOME/sushi/render_markdown.py"
ln -s "$here/viewers/markdown.js" "$XDG_DATA_HOME/sushi/viewers/markdown.js"

GI_TYPELIB_PATH=/usr/lib/x86_64-linux-gnu/sushi/girepository-1.0 \
LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/sushi \
gjs -c "
const {Gio, GLib} = imports.gi;
const res = Gio.Resource.load('/usr/share/sushi/org.gnome.NautilusPreviewer.src.gresource');
res._register();
imports.searchPath.unshift('resource:///org/gnome/NautilusPreviewer/js');
window.pkg = { pkgdatadir: '/usr/share/sushi', name: 'org.gnome.NautilusPreviewer' };
window._ = (s) => s;
imports.gi.versions.Gtk = '3.0';
imports.gi.versions.Gdk = '3.0';
imports.gi.versions.GtkSource = '4';
imports.gi.versions.EvinceDocument = '3.0';
imports.gi.versions.EvinceView = '3.0';
imports.gi.versions.Gst = '1.0';
imports.gi.versions.GstTag = '1.0';
imports.gi.versions.Soup = '3.0';
const {Gtk} = imports.gi;
Gtk.init(null);
const MimeHandler = imports.ui.mimeHandler;
let klass = MimeHandler.getKlass('text/markdown');
if (klass.name !== 'MarkdownRenderer') {
    throw new Error('Expected MarkdownRenderer, got ' + klass.name);
}
let f = Gio.File.new_for_path('$tmpdir/sample.md');
let info = f.query_info('*', Gio.FileQueryInfoFlags.NONE, null);
let r = new klass(f, info);
let tb = r.toolbar;
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => {
    if (!tb.get_visible() || !tb.box.get_visible()) {
        throw new Error('Toolbar was not made visible');
    }
    print('   OK: Resolved MarkdownRenderer and verified toolbar visibility.');
    imports.system.exit(0);
});
Gtk.main();
"

echo "All tests passed."
