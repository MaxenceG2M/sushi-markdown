# sushi-markdown

Full Markdown rendering for GNOME Files (Nautilus) spacebar preview (`gnome-sushi`).

Pressing <kbd>Space</kbd> or <kbd>Ctrl</kbd>+<kbd>Space</kbd> on a `.md` file in GNOME Files renders styled GitHub-flavored Markdown with syntax highlighting, clickable relative `.md` links, Back/Forward history navigation, and a live Raw/Rendered toggle—without patching or recompiling `gnome-sushi`.

```bash
git clone https://github.com/citizenu03bb/sushi-markdown && cd sushi-markdown && ./install.sh
```

## Why

Out of the box, `gnome-sushi` has no viewer registered for `text/markdown`. When you preview a `.md` file, Sushi's `mimeHandler.js` falls back to its parent MIME type (`text/plain`) and opens the raw source in a `GtkSource.View` buffer.

However, `mimeHandler.js` appends `~/.local/share/sushi` to GJS's `imports.searchPath` before enumerating `imports.viewers`. Because GJS merges directories across `searchPath`, dropping a viewer module into `~/.local/share/sushi/viewers/markdown.js` registers an exact match for `text/markdown` and `text/x-markdown` that takes precedence over `text/plain` while surviving package upgrades.

## Features

- **GitHub-flavored Markdown:** Tables, fenced code blocks with Pygments syntax highlighting, task lists (`- [x]`), GitHub alerts (`> [!NOTE]`, `> [!WARNING]`, etc.), and collapsible YAML frontmatter.
- **In-preview `.md` link navigation:** Clicking relative links to other `.md` files (including extensionless wiki links like `[Setup](./setup)`, directory links resolving `README.md` / `index.md`, and cross-file `#anchor` links) renders the target Markdown file in-place and updates the window titlebar and **Open With…** button.
- **Local non-Markdown links:** Clicking a relative link to an image, PDF, or code file hands it off to Sushi's native viewer for that file type. External `http(s)://` and `mailto:` links open in your default browser.
- **Back / Forward history & Raw toggle:**
  - Persistent `<` / `>` and `>_` (Raw/Rendered) buttons in the top HeaderBar, plus the bottom floating OSD toolbar.
  - Keyboard shortcuts: <kbd>Alt</kbd>+<kbd>Left</kbd> / <kbd>Backspace</kbd> (Back), <kbd>Alt</kbd>+<kbd>Right</kbd> (Forward), <kbd>Ctrl</kbd>+<kbd>U</kbd> (toggle Raw Markdown source vs. Rendered HTML), and mouse Back/Forward buttons.
- **Dark / Light theme aware:** Follows `org.gnome.desktop.interface` (`color-scheme` and `gtk-theme`), switching both page styling and Pygments themes (`monokai` / `friendly`).
- **Fixes upstream Sushi 50 toolbar visibility:** Works around the `gnome-sushi` 50 bug where `MainWindow._embedRenderer()` attaches `RendererToolbar` after `MainWindow.show_all()` without calling `toolbar.show_all()`.

## Install

Requires `gnome-sushi`, `python3-markdown`, and `python3-pygments` (plus `gir1.2-webkit2-4.1`, already pulled in by `gnome-sushi`).

On Ubuntu / Debian:

```bash
sudo apt install gnome-sushi python3-markdown python3-pygments
```

Install the viewer into `~/.local/share/sushi`:

```bash
git clone https://github.com/citizenu03bb/sushi-markdown
cd sushi-markdown
./install.sh
```

`install.sh` symlinks `viewers/markdown.js` and `render_markdown.py` into `~/.local/share/sushi/` and restarts `org.gnome.NautilusPreviewer`.

To remove:

```bash
./uninstall.sh
```

## Keyboard & Mouse Shortcuts

| Shortcut | Action |
|---|---|
| <kbd>Space</kbd> / <kbd>Ctrl</kbd>+<kbd>Space</kbd> | Open or close preview in GNOME Files |
| <kbd>Alt</kbd>+<kbd>Left</kbd> / <kbd>Backspace</kbd> / Mouse Back | Previous `.md` file in history |
| <kbd>Alt</kbd>+<kbd>Right</kbd> / Mouse Forward | Next `.md` file in history |
| <kbd>Ctrl</kbd>+<kbd>U</kbd> | Toggle between Rendered HTML and Raw Markdown source |
| <kbd>f</kbd> / <kbd>F11</kbd> | Toggle fullscreen |

## Layout

```text
sushi-markdown/
├── render_markdown.py     # Python Markdown -> standalone HTML + Pygments + key/anchor bridge
├── viewers/
│   └── markdown.js        # GJS WebKit2 + GtkSourceView Sushi Renderer implementation
├── install.sh             # Symlinks into ~/.local/share/sushi & restarts Sushi
├── uninstall.sh           # Removes symlinks & restarts Sushi
└── tests/
    └── run.sh             # Automated Python + GJS test suite
```

## Tests

```bash
tests/run.sh
```
