local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')
local layout = require('utils.tabbar-layout')

local M = {}

---Áp lại background từ backdrops vào config override của window.
---@param window any
local function reapply_background(window)
   -- Only reapply if we have backdrop images loaded
   if #backdrops.images == 0 then
      return
   end
   local overrides = window:get_config_overrides() or {}
   -- Dùng lại đúng options của backdrops thay vì tự viết lại bảng layer.
   -- Bản tự viết trước đây khác hẳn (width/height '100%' làm méo tỉ lệ ảnh,
   -- opacity khác, thiếu hsb dimming, thiếu lớp nền đục) nên mỗi lần
   -- window resize — kể cả lúc mở window mới — background nhảy sang bản sáng hơn
   -- và trong suốt hơn.
   overrides.background = backdrops:current_options()
   window:set_config_overrides(overrides)
end

M.setup = function()
   wezterm.on('window-resized', function(window, _pane)
      -- Cập nhật số cột tab bar ngay khi resize để tab co lại tức thì, không đợi
      -- status_update_interval kế tiếp.
      layout.update_from_window(window)
      -- Reapply background settings when window is resized (including fullscreen toggle)
      reapply_background(window)
   end)

   -- Override `background` được lưu trong window nên KHÔNG đổi theo config reload: chỉnh
   -- opacity/brightness ảnh nền trong wezterm.lua sẽ không thấy gì cho tới khi resize.
   -- Áp lại ngay khi reload để tuning nhìn thấy tức thì.
   wezterm.on('window-config-reloaded', function(window, _pane)
      reapply_background(window)
   end)
end

return M
