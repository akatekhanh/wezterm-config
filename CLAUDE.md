# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular WezTerm terminal configuration built in Lua with advanced features including dynamic background management, GPU adapter selection, custom event handling, and sophisticated tab rendering. The codebase uses several design patterns including singletons, builders, and a custom rendering system.

## Critical Architecture Patterns

### 1. Singleton Pattern (MOST IMPORTANT)

Several core modules use the singleton pattern and return pre-initialized instances:

```lua
-- These modules return singletons - DO NOT re-initialize
local platform = require('utils.platform')      -- Already initialized
local backdrops = require('utils.backdrops')    -- Already initialized
local gpu_adapters = require('utils.gpu-adapter') -- Already initialized
```

**Key Implications:**
- These modules maintain state across the entire application
- Calling their methods modifies shared state
- `backdrops` MUST have `:set_images()` called in `wezterm.lua` (not in modules) due to WezTerm's coroutine restrictions with `wezterm.glob()`

### 2. Module Return Patterns

The codebase uses THREE distinct module return patterns:

**Pattern A: Singleton Instances (Stateful)**
```lua
-- utils/platform.lua, utils/backdrops.lua, utils/gpu-adapter.lua
return Module:init()  -- Returns pre-initialized singleton
```

**Pattern B: Setup Modules (Event Registration)**
```lua
-- events/*.lua
local M = {}
M.setup = function(opts)
   wezterm.on('event-name', handler)
end
return M
```

**Pattern C: Configuration Tables (Stateless)**
```lua
-- config/*.lua (except config/init.lua)
return {
   option_name = value,
   -- ... more options
}
```

### 3. Config Builder Pattern (`config/init.lua`)

The configuration uses a builder pattern via the `Config` class:

```lua
Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
```

**Important Details:**
- `Config:append()` warns about duplicate keys via `wezterm.log_warn()`
- Method chaining returns `self` for fluent API
- Final `.options` extracts the merged configuration table
- This file is excluded from stylua formatting to preserve alignment

### 4. Dependency Chain & Initialization Order

**CRITICAL: Modules have dependencies that must load in the correct order:**

```
wezterm.lua (entry point)
    ├── utils/platform.lua (singleton, no deps)
    ├── utils/backdrops.lua (singleton, depends on colors/custom.lua)
    │   └── :set_images() MUST be called in wezterm.lua
    ├── utils/gpu-adapter.lua (singleton, depends on platform)
    ├── events/*.setup() (register event handlers)
    └── config/init.lua (builder pattern)
        ├── config/appearance.lua (depends on gpu-adapter, backdrops, colors)
        ├── config/bindings.lua (depends on platform, backdrops)
        ├── config/domains.lua
        ├── config/fonts.lua
        ├── config/general.lua
        └── config/launch.lua
```

**Why the Order Matters:**
1. `backdrops:set_images()` uses `wezterm.glob()` which spawns a child process - fails if called in modules during initial load
2. `config/bindings.lua` references `backdrops` methods directly in key actions
3. `config/appearance.lua` calls `gpu_adapters:pick_best()` and `backdrops:initial_options()`
4. `platform` must load before `bindings` to set correct key modifiers

## Background Image System (`utils/backdrops.lua`)

The `BackDrops` class is a singleton that manages background images with specific constraints:

**Initialization Sequence (MUST follow this order):**
```lua
require('utils.backdrops')
   :set_images_dir(custom_path)  -- optional, default: wezterm.config_dir .. '/backdrops/'
   :set_focus(color)              -- optional, default: colors.custom.background
   :set_images()                  -- REQUIRED, MUST be in wezterm.lua
```

**Key Methods:**
- `:random(window)` - Select random background
- `:cycle_forward(window)` - Next background
- `:cycle_back(window)` - Previous background
- `:set_img(window, idx)` - Set specific background by index
- `:toggle_focus(window)` - Toggle between image and solid focus color
- `:choices()` - Returns InputSelector-compatible choice table

**Special Features:**
- Looks for `totoro.jpeg` or `totoro.jpg` as default image
- Supports: jpg, jpeg, png, gif, bmp, ico, tiff, pnm, dds, tga
- Uses `window:set_config_overrides()` for runtime changes
- Focus mode overlays a solid color instead of image

## Event System Architecture

The codebase uses THREE types of events:

### Type 1: Built-in WezTerm Events
```lua
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
   -- Built-in event fired by WezTerm
end)

wezterm.on('update-right-status', function(window, pane)
   -- Built-in event fired by WezTerm
end)
```

### Type 2: Custom Application Events
```lua
-- Defined in events/*.lua and triggered by key bindings
wezterm.on('background.rotate', function(window, pane)
   -- Custom event, triggered by config/bindings.lua
end)

wezterm.on('tabs.manual-update-tab-title', function(window, pane)
   -- Custom event, triggered by key binding
end)
```

### Type 3: Event Modules with Setup
All event modules in `events/` directory export a `.setup()` function that must be called in `wezterm.lua`:

```lua
-- In wezterm.lua
require('events.left-status').setup()
require('events.right-status').setup({ date_format = '%a %H:%M:%S' })
require('events.tab-title').setup({
   hide_active_tab_unseen = false,
   unseen_icon = 'circle'
})
require('events.new-tab-button').setup()
require('events.background-rotation').setup({ mode = 'cycle' }) -- or 'random'
```

**Current Event Modules:**
- `left-status.setup()` - Shows active key table (LEADER, resize_font, resize_pane)
- `right-status.setup(opts)` - Right status bar (currently empty but configured for date)
- `tab-title.setup(opts)` - Complex tab title rendering with icons, admin detection, WSL detection
- `new-tab-button.setup()` - Custom new tab button appearance
- `background-rotation.setup(opts)` - Automatic background rotation on new tab creation

## Automatic Background Rotation

Background images automatically rotate when new tabs are created:

**How it Works:**
1. `events/background-rotation.lua` registers a `background.rotate` event handler
2. Key bindings in `config/bindings.lua` emit this event when spawning new tabs (lines 73, 81)
3. The event handler calls either `backdrops:cycle_forward(window)` or `backdrops:random(window)`

**Configuration:**
```lua
require('events.background-rotation').setup({ mode = 'cycle' }) -- or 'random'
```

**Implementation Detail:**
- Rotation is tab-triggered, not time-based
- Each new tab spawn emits `EmitEvent('background.rotate')`
- For time-based rotation, would need `wezterm.time.call_after()` with recursive timers (not implemented)

## Platform-Specific Key Bindings (`config/bindings.lua`)

Key modifiers adapt to the platform to avoid OS conflicts:

**Platform Detection:**
```lua
-- Uses wezterm.target_triple string matching
if platform.is_mac then
   mod.SUPER = 'SUPER'      -- Cmd key
   mod.SUPER_REV = 'SUPER|CTRL'  -- Cmd+Ctrl
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT'        -- Alt key (avoids Windows key)
   mod.SUPER_REV = 'ALT|CTRL'    -- Alt+Ctrl
end
```

**Leader Key:**
```lua
leader = { key = 'Space', mods = mod.SUPER_REV }
```

**Background Control Bindings:**
- `SUPER + /` - Random image
- `SUPER + ,` - Previous image
- `SUPER + .` - Next image
- `SUPER_REV + /` - Fuzzy search images (InputSelector)
- `SUPER + b` - Toggle focus mode

**Key Tables:**
- `LEADER + f` - Enter `resize_font` key table
- `LEADER + p` - Enter `resize_pane` key table

## GPU Adapter Selection (`utils/gpu-adapter.lua`)

Only active when `front_end = 'WebGpu'` in `config/appearance.lua`.

**Selection Algorithm (`pick_best()`):**
1. **GPU Type Priority**: Discrete > Integrated > Other > CPU
2. **Graphics API Priority** (platform-specific):
   - Windows: Dx12 > Vulkan > OpenGL
   - Linux: Vulkan > OpenGL
   - macOS: Metal

**Fallback Chain:**
```lua
local adapters_options = self.DiscreteGpu
if not adapters_options then
   adapters_options = self.IntegratedGpu
end
if not adapters_options then
   adapters_options = self.Other
   preferred_backend = 'Gl'  -- Special case: OpenGL on discrete GPU
end
if not adapters_options then
   adapters_options = self.Cpu
end
```

**Manual Selection:**
```lua
webgpu_preferred_adapter = gpu_adapters:pick_manual('Dx12', 'IntegratedGpu')
```

## Tab Title Rendering System (`events/tab-title.lua`)

This is the most complex module, using a sophisticated rendering system:

### Components

**1. Tab State Management:**
- Maintains persistent `tab_list` table keyed by `tab.tab_id`
- Each tab stores: title, locked state, WSL/admin detection, unseen output count
- State persists across tab updates

**2. Tab Class API:**
```lua
Tab:set_info(event_opts, tab, max_width)  -- Update tab info
Tab:create_cells()                         -- Initialize cell segments
Tab:update_cells(event_opts, is_active, hover) -- Update colors/text
Tab:render()                               -- Returns FormatItem[] for wezterm.format()
Tab:update_and_lock_title(title)           -- Lock custom title
```

**3. Cells Rendering System (`utils/cells.lua`):**

The Cells class provides a declarative API for building formatted text:

```lua
cells
   :add_segment('scircle_left', GLYPH_SCIRCLE_LEFT, colors, attributes)
   :add_segment('title', ' ' .. title, colors)
   :add_segment('scircle_right', GLYPH_SCIRCLE_RIGHT, colors)
   :render({ 'scircle_left', 'title', 'scircle_right' })
```

**Key Features:**
- Segments are stored by ID (string or number)
- Colors can be updated without recreating segments
- `render(ids)` allows flexible segment ordering
- `render_all()` renders all segments (order not guaranteed for string IDs)
- Supports FormatItem attributes: Bold, Italic, Underline

**4. Detection Features:**
- **Admin Detection**: Matches `^Administrator: ` or `(Admin)` in pane title
- **WSL Detection**: Matches `^wsl` in process name
- **Unseen Output**: Counts unseen output across all panes (max 10)

**5. Render Variants:**
Six different render patterns based on tab state:
1. Basic: `scircle_left + title + padding + scircle_right`
2. With unseen: `scircle_left + title + unseen_output + padding + scircle_right`
3. Admin: `scircle_left + admin + title + padding + scircle_right`
4. Admin with unseen: `scircle_left + admin + title + unseen_output + padding + scircle_right`
5. WSL: `scircle_left + wsl + title + padding + scircle_right`
6. WSL with unseen: `scircle_left + wsl + title + unseen_output + padding + scircle_right`

**6. Options Validation (`utils/opts-validator.lua`):**

Schema-based validation system:
```lua
EVENT_OPTS.schema = {
   {
      name = 'unseen_icon',
      type = 'string',
      enum = { 'circle', 'numbered_circle', 'numbered_box' },
      default = 'circle',
   },
   {
      name = 'hide_active_tab_unseen',
      type = 'boolean',
      default = true,
   },
}
```

## Development Commands

### Linting & Formatting

```bash
# Format Lua code (excludes config/init.lua)
stylua -g '!/config/init.lua' wezterm.lua colors/ config/ events/ utils/

# Check formatting without modifying
stylua -g '!/config/init.lua' --check wezterm.lua colors/ config/ events/ utils/

# Lint all files
luacheck wezterm.lua colors/* config/* events/* utils/*
```

### Testing Configuration

```bash
# WezTerm will automatically reload on file changes if:
# automatically_reload_config = true (set in config/general.lua)

# To test without reload:
wezterm --config-file /path/to/wezterm.lua

# Check for errors:
wezterm show-keys  # Lists all configured key bindings
wezterm ls-fonts   # Lists available fonts
```

### Configuration Standards

- **Line width**: 100 characters (`.stylua.toml`)
- **Indentation**: 3 spaces
- **Quote style**: Single quotes preferred (`AutoPreferSingle`)
- **Call parentheses**: Always required
- **Max line length**: 150 (luacheck), 200 for comments
- **Lua standard**: LuaJIT
- **Ignored luacheck rules**:
  - `241` (globally) - unused variables
  - `212` (backdrops.lua only) - unused argument

## Common Customization Points

Users typically customize:

1. **`config/domains.lua`** - SSH/WSL domain configurations
2. **`config/launch.lua`** - Default shell and shell paths
3. **`backdrops/` directory** - Add custom background images
4. **`config/appearance.lua`** - Colors, opacity, GPU settings
5. **`config/bindings.lua`** - Key bindings and actions

## Runtime Configuration Override Pattern

Several features use `window:set_config_overrides()` for runtime changes:

```lua
window:set_config_overrides({
   background = new_background_opts,
   enable_tab_bar = window:effective_config().enable_tab_bar,
})
```

**Critical Detail:**
- Always include `enable_tab_bar` when overriding to preserve its state
- Use `window:effective_config()` to get current config state
- Overrides persist until window closes or overridden again

## Color System (`colors/custom.lua`)

Custom Catppuccin Mocha variant with modified base color:

```lua
base = '#1f1f28'  -- Modified from standard Catppuccin Mocha
```

**Usage in other modules:**
```lua
local colors = require('colors.custom')
colors.background  -- Used as default focus color in backdrops
```

## State Management Patterns

### 1. Global Singleton State
- `backdrops` - Current image index, focus mode, images list
- `platform` - OS detection results
- `gpu_adapters` - Adapter maps by device type

### 2. Window-Specific State
- Background images (via `window:set_config_overrides()`)
- Tab bar visibility (via config overrides)
- Window dimensions (via `window:get_dimensions()`)

### 3. Tab-Specific State
- Tab titles (in `tab_list` table keyed by `tab_id`)
- Lock state for custom titles
- Per-tab WSL/admin detection

### 4. Event-Driven State
- Active key table (LEADER, resize_font, resize_pane)
- Leader key activation state

## Gotchas & Common Pitfalls

1. **DON'T call `backdrops:set_images()` in module files** - Only in `wezterm.lua` due to coroutine restrictions

2. **DON'T modify singleton state casually** - `backdrops`, `platform`, `gpu_adapters` are shared across entire config

3. **DON'T forget `.options` at the end of the builder chain** - `Config:init():append(...).options`

4. **DON'T use `render_all()` with string segment IDs expecting order** - Use `render(ids)` for guaranteed order

5. **DON'T forget to preserve `enable_tab_bar` in config overrides** - Always read current value first

6. **DO call event module `.setup()` functions** - They register event handlers, not just return config

7. **DO use method chaining consistently** - Backdrops and Config both use fluent APIs

8. **DO validate options** - Use `OptsValidator` for user-configurable event options

9. **DO understand module return patterns** - Singleton vs Setup vs Config Table patterns are different

10. **DO respect stylua exclusions** - `config/init.lua` is intentionally excluded for formatting

## File Organization Philosophy

```
wezterm.lua           -- Entry point, initializes singletons, registers events
├── config/           -- Configuration tables (stateless)
│   ├── init.lua      -- Builder pattern (special, excluded from stylua)
│   ├── appearance.lua
│   ├── bindings.lua
│   ├── domains.lua
│   ├── fonts.lua
│   ├── general.lua
│   └── launch.lua
├── events/           -- Event registration modules (setup pattern)
│   ├── left-status.lua
│   ├── right-status.lua
│   ├── tab-title.lua
│   ├── new-tab-button.lua
│   └── background-rotation.lua
├── utils/            -- Utilities and singletons
│   ├── backdrops.lua      -- Singleton (stateful)
│   ├── platform.lua       -- Singleton (stateful)
│   ├── gpu-adapter.lua    -- Singleton (stateful)
│   ├── cells.lua          -- Class (rendering engine)
│   ├── opts-validator.lua -- Class (validation)
│   └── math.lua           -- Utilities (stateless)
├── colors/           -- Color schemes
│   └── custom.lua
└── backdrops/        -- Background images (user content)
```

## Quick Key Binding Reference

Key modifiers adapt by platform (see `config/bindings.lua`):
- **macOS**: `SUPER` = Cmd, `SUPER_REV` = Cmd+Ctrl
- **Windows/Linux**: `SUPER` = Alt, `SUPER_REV` = Alt+Ctrl
- **Leader key**: `SUPER_REV + Space`

**Essential bindings:**
| Keys | Action |
|------|--------|
| `F12` | Debug overlay |
| `SUPER + /` | Random background |
| `SUPER + b` | Toggle focus mode |
| `SUPER + t` | New tab |
| `SUPER + \` | Split vertical |
| `LEADER + f` | Enter font resize mode |
| `LEADER + p` | Enter pane resize mode |

See `README.md` for complete key binding tables.

## Backdrop Images

For comprehensive backdrop recommendations, image sources, and technical specifications, see `docs/BACKDROP_GUIDE.md`.

**Quick reference:**
- Images stored in `backdrops/` directory
- Supports: jpg, jpeg, png, gif, bmp, ico, tiff, pnm, dds, tga
- Current opacity: 0.3 with brightness 0.3 (configured in `config/appearance.lua`)
- Focus mode (`SUPER + b`) shows solid color instead of image

## Advanced Debugging

**Enable Debug Logging:**
```lua
-- Add to wezterm.lua
wezterm.log_info('Message')   -- Info level
wezterm.log_warn('Message')   -- Warning level
wezterm.log_error('Message')  -- Error level
```

**Debug Overlay:**
- Press `F12` to show debug overlay
- Shows Lua errors, performance metrics, GPU info

**Check GPU Selection:**
```lua
-- In config/appearance.lua
wezterm.log_info('Selected GPU:', gpu_adapters:pick_best())
```

**Test Event Registration:**
```lua
-- Verify events are registered
wezterm.log_info('Registering event: background.rotate')
```
