local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')
local layout = require('utils.tabbar-layout')

local M = {}

---@param a table|nil
---@param b table|nil
---@return boolean
local function backgrounds_equal(a, b)
   if type(a) ~= 'table' or type(b) ~= 'table' or #a ~= #b then
      return false
   end
   for i = 1, #a do
      local la, lb = a[i], b[i]
      if type(la) ~= 'table' or type(lb) ~= 'table' then
         return false
      end
      local sa, sb = la.source or {}, lb.source or {}
      if sa.File ~= sb.File or sa.Color ~= sb.Color or la.opacity ~= lb.opacity then
         return false
      end
      local ha, hb = la.hsb or {}, lb.hsb or {}
      if ha.brightness ~= hb.brightness or ha.saturation ~= hb.saturation or ha.hue ~= hb.hue then
         return false
      end
   end
   return true
end

---Áp lại background từ backdrops vào config override của window.
---@param window any
---@param force boolean?
local function reapply_background(window, force)
   -- Only reapply if we have backdrop images loaded
   if #backdrops.images == 0 then
      return
   end
   local overrides = window:get_config_overrides() or {}
   local desired = backdrops:current_options()
   -- Avoid redundant set_config_overrides() inside window-config-reloaded loops.
   if not force and backgrounds_equal(overrides.background, desired) then
      return
   end
   overrides.background = desired
   window:set_config_overrides(overrides)
end

M.setup = function()
   wezterm.on('window-resized', function(window, _pane)
      -- Cập nhật số cột tab bar ngay khi resize để tab co lại tức thì, không đợi
      -- status_update_interval kế tiếp.
      layout.update_from_window(window)
      -- Reapply background settings when window is resized (including fullscreen toggle)
      reapply_background(window, true)
   end)

   -- Override `background` được lưu trong window nên KHÔNG đổi theo config reload: chỉnh
   -- opacity/brightness ảnh nền trong wezterm.lua sẽ không thấy gì cho tới khi resize.
   -- Áp lại ngay khi reload để tuning nhìn thấy tức thì.
   wezterm.on('window-config-reloaded', function(window, _pane)
      reapply_background(window, false)
   end)
end

return M
