# A reasonable Emacs config

This configuration is a fork of [Steve Purcell's emacs.d](https://github.com/purcell/emacs.d). It is split into many init modules and supports an **install mode** so you can run a smaller subset (e.g. text-only or programming-only).

## Completion and navigation

* **Minibuffer**: [Ivy](https://github.com/abo-abo/swiper) and [Counsel](https://github.com/abo-abo/swiper) for finding buffers, files, commands, and more.
* **In-buffer completion**: [Company](https://company-mode.github.io/) for completion at point, with optional company-quickhelp.

## Syntax checking

[Flycheck](http://www.flycheck.org) is used to highlight syntax and lint errors on the fly in supported languages (e.g. Ruby, Python, JavaScript, and others). Optional flycheck-color-mode-line is supported.

## Themes and appearance

* Default theme: **sanityinc-tomorrow-bright** (dark). Custom themes `sanityinc-tomorrow` and `sanityinc-solarized` are installed.
* Commands `light` and `dark` switch between light and dark themes.
* [dimmer](https://github.com/gaida/dimmer) dims inactive windows.
* Customization is stored in `custom.el` in the config directory.

## Install mode

In `init.el`, set:

```el
(setq install-mode "full")   ; or "text" or "programming"
```

* **full**: All language and feature modules (default).
* **text**: Skips programming-only modules (e.g. nxml, html, python, cc-mode, multi-term) but still loads org, markdown, tex, blog, etc.
* **programming**: Skips text-oriented modules (markdown, tex, company-math, blog).

Language and feature support is loaded according to this mode (see the `when (not (string-equal install-mode ...))` blocks in `init.el`).

## Main tools and features

* **Version control**: [Magit](https://magit.vc/) (e.g. `C-x g`), git-modes, git-link, optional git-timemachine and magit-todos.
* **Projects**: [Projectile](https://github.com/bbatsov/projectile) (completion via Ivy).
* **Org-mode**: Agenda, GTD-style setup, clocking, store/link keys (`C-c l`, `C-c a`, `C-c o`).
* **Sessions**: Desktop and session packages to restore buffers on restart.
* **Other**: Dired, Neotree, Deft, code-library, yasnippet, compile, CSV, Ledger, dash, folding, and others.

## Language and format support (when loaded by install mode)

Representative support (via init-*.el modules) includes:

* **Markup / docs**: HTML (nxml), Markdown, Tex/LaTeX, Org, Deft, blog.
* **Languages**: C/C++ (cc-mode), Python, YAML, Lisp (Emacs Lisp, Paredit), Common Lisp (Slime), and related tooling.
* **Other**: CSV, Ledger, spelling (when `*spell-check-support-enabled*` is t).

Additional language modules exist in `lisp/` (e.g. Rust, Ruby, Haskell, JavaScript, Clojure, etc.) but are not required from the main `init.el`; you can `(require 'init-<name>)` in `init-local.el` or add them to `init.el` if you want them.

## Requirements

* **Emacs**: 27.1 or newer (28.1+ recommended). The config degrades on older versions.
* **Packages**: Installed automatically from MELPA on first run. For language-specific checks, external tools used by Flycheck may be required.

## Emacs build

### System dependencies (Debian/Ubuntu)

Install the libraries and headers needed for the Emacs build:

```bash
sudo apt update
sudo apt install -y \
  build-essential \
  libgtk-3-dev \
  libcairo2-dev \
  libgccjit-10-dev \
  imagemagick \
  libmagickwand-dev \
  libmagickcore-dev \
  libtree-sitter-dev \
  libtree-sitter0 \
  sqlite3 \
  libsqlite3-dev \
  libmailutils-dev \
  libxml2-dev \
  libgif-dev \
  libpng-dev \
  libjpeg-dev \
  libaspell-dev
```

### Configure and build

This configuration is intended for an Emacs built with the following `./configure` options (native compilation AOT, tree-sitter, and the listed libraries/toolkits):

```bash
./configure --with-native-compilation=aot \
            --with-tree-sitter \
            --with-modules \
            --with-threads \
            --with-mailutils \
            --with-imagemagick \
            --without-xaw3d \
            --with-x-toolkit=gtk3 \
            --without-toolkit-scroll-bars \
            --with-cairo
```

Build Emacs from source with these options if you want the same environment; some packages (e.g. tree-sitter) depend on the corresponding support in the binary.

## Installation

Clone this repo so that `init.el` is at `~/.emacs.d/init.el`:

```bash
git clone <your-repo-url> ~/.emacs.d
```

Start Emacs; packages will be installed on first run. If needed, run `M-x package-refresh-contents` and restart.

## Updates

* Pull config changes: `git pull`.
* Update packages: `M-x package-list-packages`, then `U` and `x`.
* Restart Emacs after pulling or upgrading so sessions and packages apply correctly.

## Customization

* **Personal settings**: Use `M-x customize` / `M-x customize-themes`, and/or edit:
  * `lisp/init-local.el` — loaded at the end of startup (create it if missing).
  * `lisp/init-preload-local.el` — loaded early, before most feature modules (optional).
* **Spell checking**: Set `*spell-check-support-enabled*` in `init.el` (default is `t`).
* **Install mode**: Set `install-mode` in `init.el` to `"full"`, `"text"`, or `"programming"` as above.

Example `lisp/init-local.el`:

```el
;; your code here ...
(provide 'init-local)
```

Custom values from the customize interface are stored in `custom.el` (gitignored).

---

Based on [purcell/emacs.d](https://github.com/purcell/emacs.d).
