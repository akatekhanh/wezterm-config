local wezterm = require('wezterm')

local M = {}

-- Red theme for khanhpc
local khanhpc_colors = {
   foreground = '#FFFFFF',
   background = '#1a0000',
   cursor_bg = '#ff4444',
   cursor_fg = '#000000',
   cursor_border = '#ff4444',
   selection_fg = '#000000',
   selection_bg = '#ff4444',
   ansi = {
      '#1a0000',
      '#ff6666',
      '#66ff66',
      '#ffff66',
      '#6666ff',
      '#ff66ff',
      '#66ffff',
      '#ffffff',
   },
   brights = {
      '#552222',
      '#ff8888',
      '#88ff88',
      '#ffff88',
      '#8888ff',
      '#ff88ff',
      '#88ffff',
      '#ffffff',
   },
}

function M.setup()
   wezterm.on('trigger-khanhpc-theme', function(window, pane)
      local domain_name = pane:get_domain_name() or ''
      local title = pane:get_title() or ''

      -- Check if connected to khanhpc
      if domain_name == 'khanhpc' or title:match('khanhpc') or title:match('akatekhanh') then
         window:set_config_overrides({
            colors = khanhpc_colors,
            window_frame = {
               active_titlebar_bg = '#330000',
               inactive_titlebar_bg = '#1a0000',
            },
         })
      end
   end)
end

return M
