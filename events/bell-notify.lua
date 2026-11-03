-- Thông báo macOS khi có bell lúc đang làm việc ở app khác (Claude Code xong việc rung
-- bell, tmux chuyển tiếp qua `bell-action any`). Đang nhìn WezTerm thì không báo: đã có
-- visual_bell và cờ của tmux.
local wezterm = require('wezterm')

local M = {}

local THROTTLE_SECONDS = 10
local TIMEOUT_MS = 5000
local last_at = 0

M.setup = function()
   wezterm.on('bell', function(window, pane)
      if window:is_focused() then
         return
      end
      local now = os.time()
      if now - last_at < THROTTLE_SECONDS then
         return
      end
      last_at = now
      window:toast_notification('WezTerm', pane:get_title(), nil, TIMEOUT_MS)
   end)
end

return M
