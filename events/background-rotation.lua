local wezterm = require('wezterm')

local M = {}

---Setup automatic background rotation when new tabs are created
---@param opts table|nil configuration options
---   - mode: 'cycle' | 'random' (default: 'cycle')
function M.setup(opts)
   opts = opts or {}
   local mode = opts.mode or 'cycle'

   wezterm.on('background.rotate', function(window, _pane)
      local backdrops = require('utils.backdrops')

      -- Rotate background based on mode
      if mode == 'random' then
         backdrops:random(window)
      else
         backdrops:cycle_forward(window)
      end
   end)
end

return M
