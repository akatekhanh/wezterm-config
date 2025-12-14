<h2 align="center">akatekhanh's WezTerm Config</h2>

<p align="center">
  <a href="https://github.com/akatekhanh/wezterm-config/stargazers">
    <img alt="Stargazers" src="https://img.shields.io/github/stars/akatekhanh/wezterm-config?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41">
  </a>
  <a href="https://github.com/akatekhanh/wezterm-config/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/akatekhanh/wezterm-config?style=for-the-badge&logo=gitbook&color=B5E8E0&logoColor=D9E0EE&labelColor=302D41">
  </a>
</p>

<p align="center">
  A modular WezTerm configuration with dynamic backgrounds, GPU optimization, and Catppuccin Mocha aesthetics.
</p>

![screenshot](./.github/screenshots/wezterm.gif)

---

## Features

- **Dynamic Background System** - Cycle through 25+ curated anime & space wallpapers
- **Smart GPU Selection** - Auto-selects best GPU/graphics API for WebGpu
- **Platform-Adaptive Keys** - Same shortcuts work across macOS, Windows, Linux
- **Custom Tab Rendering** - Admin/WSL detection, unseen output indicators
- **Focus Mode** - Toggle solid background for distraction-free coding

---

## Quick Start

```sh
# Backup existing config (if any)
mv ~/.config/wezterm ~/.config/wezterm.bak

# Clone this config
git clone https://github.com/akatekhanh/wezterm-config.git ~/.config/wezterm
```

**Requirements:**
- [WezTerm](https://wezfurlong.org/wezterm/installation.html) (v20240127+ recommended)
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)

---

## Key Bindings

> **SUPER** = `Cmd` (macOS) / `Alt` (Windows/Linux)
> **SUPER_REV** = `Cmd+Ctrl` (macOS) / `Alt+Ctrl` (Windows/Linux)
> **LEADER** = `SUPER_REV + Space`

### Essential

| Keys | Action |
|------|--------|
| `SUPER + t` | New tab |
| `SUPER + w` | Close pane |
| `SUPER + \` | Split vertical |
| `SUPER_REV + \` | Split horizontal |
| `SUPER + Enter` | Toggle pane zoom |
| `F12` | Debug overlay |

### Navigation

| Keys | Action |
|------|--------|
| `SUPER + [` / `]` | Previous/Next tab |
| `SUPER_REV + h/j/k/l` | Move between panes |
| `SUPER + u` / `d` | Scroll up/down |

### Backgrounds

| Keys | Action |
|------|--------|
| `SUPER + /` | Random background |
| `SUPER + ,` / `.` | Cycle backgrounds |
| `SUPER_REV + /` | Fuzzy search backgrounds |
| `SUPER + b` | Toggle focus mode |

### Key Tables

| Keys | Action |
|------|--------|
| `LEADER + f` | Font resize mode (`j/k` to resize, `q` to exit) |
| `LEADER + p` | Pane resize mode (`h/j/k/l` to resize, `q` to exit) |

---

## Customization

| File | Purpose |
|------|---------|
| `config/appearance.lua` | Colors, opacity, GPU settings |
| `config/bindings.lua` | Key bindings |
| `config/fonts.lua` | Font family and size |
| `config/domains.lua` | SSH/WSL domains |
| `config/launch.lua` | Default shell |
| `backdrops/` | Background images |

---

## Structure

```
wezterm.lua           # Entry point
├── config/           # Configuration modules
├── events/           # Event handlers (tab titles, status bar)
├── utils/            # Utilities (backdrops, GPU, platform detection)
├── colors/           # Color schemes (Catppuccin Mocha)
└── backdrops/        # Background images
```

---

## Credits

Based on [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)

**Inspirations:**
- [catppuccin/wezterm](https://github.com/catppuccin/wezterm)
- [WezTerm Show & Tell](https://github.com/wez/wezterm/discussions/628)
