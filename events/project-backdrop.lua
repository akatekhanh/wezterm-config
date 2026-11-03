-- Đổi ảnh nền theo project.
--
-- tmux đặt tiêu đề terminal = tên session (`set-titles-string "#S"` trong ~/.tmux.conf).
-- Mỗi giây (update-status) đọc tiêu đề của pane đang active; nếu pane đang chạy tmux và
-- tiêu đề đổi → chọn một ảnh trong backdrops/ theo tên session và áp dụng. Cùng tên
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

---Trộn bit (murmur3 finalizer). `hash` đa thức một mình không đủ để so điểm: thứ tự giữa
---các ảnh gần như không phụ thuộc tên session, nên 200 session chỉ rơi vào 3 ảnh.
---@param h number
---@return number
local function mix(h)
   h = h ~ (h >> 16)
   h = (h * 0x85ebca6b) & 0xffffffff
   h = h ~ (h >> 13)
   h = (h * 0xc2b2ae35) & 0xffffffff
   return h ~ (h >> 16)
end

---Rendezvous hashing: mỗi cặp (session, ảnh) có một điểm, ảnh điểm cao nhất thắng.
---Không dùng `hash % số_ảnh` vì thêm/xoá một ảnh sẽ làm gần như MỌI project đổi ảnh;
---cách này chỉ đổi những project mà ảnh mới thắng (hoặc ảnh bị xoá đang được dùng).
---@param title string
---@param images string[]
---@return number idx
local function pick_image(title, images)
   local title_hash = hash(title)
   local best_idx, best_score = 1, -1
   for idx, file in ipairs(images) do
      local score = mix(hash(file:match('([^/\\]+)$')) ~ title_hash)
      if score > best_score then
         best_idx, best_score = idx, score
      end
   end
   return best_idx
end

---@param pane any
---@return boolean
local function is_tmux(pane)
   local proc = pane:get_foreground_process_name() or ''
   return proc:match('[/\\]?tmux[^/\\]*$') ~= nil
end

M.pick_image = pick_image

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

         backdrops:set_index(window, pick_image(title, backdrops.images))
      end)
      if not ok then
         wezterm.log_warn('project-backdrop: ' .. tostring(err))
      end
   end)
end

return M
