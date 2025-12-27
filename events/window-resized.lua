local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')

local M = {}

M.setup = function()
   wezterm.on('window-resized', function(window, pane)
      -- Reapply background settings when window is resized (including fullscreen toggle)
      local overrides = window:get_config_overrides() or {}

      -- Only reapply if we have backdrop images loaded
      if #backdrops.images > 0 then
         if backdrops.focus_on then
            overrides.background = {
               {
                  source = { Color = backdrops.focus_color },
                  height = '120%',
                  width = '120%',
                  vertical_offset = '-10%',
                  horizontal_offset = '-10%',
                  opacity = 1,
               },
            }
         else
            overrides.background = {
               {
                  source = { File = backdrops.images[backdrops.current_idx] },
                  horizontal_align = 'Center',
                  vertical_align = 'Middle',
                  width = '100%',
                  height = '100%',
                  repeat_x = 'NoRepeat',
                  repeat_y = 'NoRepeat',
                  opacity = 0.3,
               },
            }
         end

         window:set_config_overrides(overrides)
      end
   end)
end

return M
