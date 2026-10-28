-- Đổi ảnh nền theo project.
--
-- tmux đặt tiêu đề terminal = tên session (`set-titles-string "#S"` trong ~/.tmux.conf).
-- Mỗi giây (update-status) đọc tiêu đề của pane đang active; nếu pane đang chạy tmux và
-- tiêu đề đổi → băm tên session ra một chỉ số ảnh trong backdrops/ và áp dụng. Cùng tên
-- luôn ra cùng ảnh, nên chuyển project là đổi "không khí", quay lại là ảnh cũ.
--
-- Không đụng tới rotation thủ công (events/background-rotation.lua): xoay tay vẫn được,
-- nhưng lần đổi session kế tiếp sẽ kéo về ảnh của project đó.
local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')

local M = {}

---@type table<number, string> window_id → tiêu đề lần cuối đã xử lý
local last_title = {}

---@param s string
---@return number
local function hash(s)
   local h = 0
   for i = 1, #s do
      h = (h * 31 + s:byte(i)) % 2147483647
   end
   return h
end

---@param pane any
---@return boolean
local function is_tmux(pane)
   local proc = pane:get_foreground_process_name() or ''
   return proc:match('[/\\]?tmux[^/\\]*$') ~= nil
end

M.setup = function()
   wezterm.on('update-status', function(window, pane)
      if #backdrops.images == 0 then
         return
      end

      local ok, err = pcall(function()
         if not is_tmux(pane) then
            return
         end
         local title = pane:get_title() or ''
         if title == '' then
            return
         end
         local wid = window:window_id()
         if last_title[wid] == title then
            return
         end
         last_title[wid] = title

         local idx = (hash(title) % #backdrops.images) + 1
         backdrops:set_index(window, idx)
      end)
      if not ok then
         wezterm.log_warn('project-backdrop: ' .. tostring(err))
      end
   end)
end

return M
