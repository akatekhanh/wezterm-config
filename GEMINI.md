# Gemini Code Assistant Context

This document provides context for the Gemini code assistant to understand the structure and conventions of this Wezterm configuration repository.

## Project Overview

This is a highly modular and feature-rich configuration for the [WezTerm terminal emulator](https://wezfurlong.org/wezterm/). The configuration is written entirely in Lua and is designed to be easily customizable.

The core philosophy is to split concerns into different directories and files, which are then loaded and composed by the main `wezterm.lua` entry point.

### Key Features:
- **Modular Structure:** Configuration is broken down into `config`, `events`, and `utils` for clarity.
- **Dynamic Backgrounds:** The terminal background can be cycled through a curated list of images located in the `backdrops/` directory.
- **GPU Optimization:** Automatically selects the most performant graphics adapter for rendering.
- **Custom UI:** Includes custom-rendered left and right status bars, tab titles that indicate unseen output, and a new tab button.
- **Cross-Platform Bindings:** Key mappings are designed to work consistently across macOS, Windows, and Linux.

## Project Structure

```
wezterm.lua           # Main entry point, loads all other modules
├── config/           # Core configuration modules
│   ├── appearance.lua  # Colors, fonts, opacity, window settings
│   ├── bindings.lua    # Key and mouse bindings
│   └── init.lua        # Helper to chain configuration tables
├── events/           # Event handlers for the WezTerm GUI
│   ├── background-rotation.lua # Cycles the window background
│   ├── left-status.lua # Renders the left side of the status bar
│   ├── right-status.lua # Renders the right side of the status bar
│   └── tab-title.lua   # Customizes tab titles
├── utils/            # Utility functions and helpers
│   ├── backdrops.lua   # Manages the background image list and rotation
│   ├── platform.lua    # Platform-specific helpers
│   └── gpu-adapter.lua # Logic for selecting the best GPU
├── colors/           # Color schemes
└── backdrops/        # Directory for background images
```

## Running the Configuration

This project doesn't have a traditional "build" or "run" step. It is a configuration that is loaded by the WezTerm application itself.

To install and use this configuration:
1.  Ensure [WezTerm](https://wezfurlong.org/wezterm/installation.html) is installed.
2.  Clone this repository to the correct configuration path:
    ```sh
    # First, back up your existing configuration
    mv ~/.config/wezterm ~/.config/wezterm.bak

    # Clone the repository
    git clone https://github.com/akatekhanh/wezterm-config.git ~/.config/wezterm
    ```
3.  Restart WezTerm to apply the new configuration.

## Development Conventions

The project uses `stylua` for code formatting and `luacheck` for linting to maintain code quality and consistency. These checks are enforced in CI via a GitHub Actions workflow (`.github/workflows/lint.yml`).

### Formatting (`stylua`)
To check if files are formatted correctly, run:
```sh
stylua --check wezterm.lua colors/ config/ events/ utils/
```
To format the files, run the same command without the `--check` flag.

### Linting (`luacheck`)
To lint the codebase, run:
```sh
luacheck wezterm.lua colors/* config/* events/* utils/*
```
The `.luacheckrc` file contains the specific linting rules and globals for the WezTerm API.
