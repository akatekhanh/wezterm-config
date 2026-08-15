local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')

local M = {}

M.setup = function()
   wezterm.on('window-resized', function(window, pane)
      -- Reapply background settings when window is resized (including fullscreen toggle)
      local overrides = window:get_config_overrides() or {}

      -- Only reapply if we have backdrop images loaded
      if #backdrops.images > 0 then
         -- Dùng lại đúng options của backdrops thay vì tự viết lại bảng layer.
         -- Bản tự viết trước đây khác hẳn (width/height '100%' làm méo tỉ lệ ảnh,
         -- opacity 0.3 thay vì 0.18, thiếu hsb dimming, thiếu lớp nền đục) nên mỗi lần
         -- window resize — kể cả lúc mở window mới — background nhảy sang bản sáng hơn
         -- và trong suốt hơn.
         overrides.background = backdrops:current_options()
         window:set_config_overrides(overrides)
      end
   end)
end

return M
