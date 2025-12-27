local wezterm = require 'wezterm'

local M = {}

function M.setup()
  wezterm.on('window-state-changed', function(window, pane)
    local dims = window:get_dimensions()
    local overrides = window:get_config_overrides() or {}

    if dims.is_fullscreen then
      overrides.window_background_opacity = 0.8
    else
      overrides.window_background_opacity = 1.0
    end

    window:set_config_overrides(overrides)
  end)
end

return M
