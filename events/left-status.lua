local wezterm = require('wezterm')
local Cells = require('utils.cells')
local ui = require('colors.palette').ui

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

-- Enhanced glyphs with modern iconography
local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_KEY_TABLE = nf.md_table_key --[[ '󱏅' ]]
local GLYPH_KEY = nf.md_key --[[ '󰌆' ]]
local GLYPH_GIT_BRANCH = nf.dev_git_branch --[[ '' ]]
local GLYPH_FOLDER = nf.md_folder --[[ '󰉋' ]]
local GLYPH_PANES = nf.md_view_grid --[[ '󰕰' ]]
local GLYPH_SEPARATOR = nf.ple_left_half_circle_thin --[[ '' ]]

---@type table<string, Cells.SegmentColors>
-- Màu lấy từ colors/palette.lua — không hardcode hex ở đây.
local colors = {
   -- Key table (ưu tiên cao nhất - accent ấm)
   key_bg = { bg = ui.accent_key, fg = ui.on_accent },
   key_scircle = { bg = ui.glass, fg = ui.accent_key },

   -- Git branch (ưu tiên hai - accent lạnh)
   git_bg = { bg = ui.accent_git, fg = ui.on_accent },
   git_scircle = { bg = ui.glass, fg = ui.accent_git },

   -- Thư mục hiện tại (ưu tiên ba - nền trầm)
   dir_bg = { bg = ui.dir_bg, fg = ui.dir_fg },
   dir_scircle = { bg = ui.glass, fg = ui.dir_bg },

   -- Số pane trong window
   panes_bg = { bg = ui.accent_panes, fg = ui.on_accent },
   panes_scircle = { bg = ui.glass, fg = ui.accent_panes },

   separator = { bg = ui.glass, fg = ui.separator },
}

local cells = Cells:new()

-- Initialize segments with proper spacing
cells
   -- Key table indicator
   :add_segment('key_left', GLYPH_SEMI_CIRCLE_LEFT, colors.key_scircle, attr(attr.intensity('Bold')))
   :add_segment('key_icon', ' ', colors.key_bg, attr(attr.intensity('Bold')))
   :add_segment('key_text', ' ', colors.key_bg, attr(attr.intensity('Bold')))
   :add_segment('key_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.key_scircle, attr(attr.intensity('Bold')))
   -- Separator
   :add_segment('separator1', ' ' .. GLYPH_SEPARATOR .. ' ', colors.separator)
   -- Git branch
   :add_segment('git_left', GLYPH_SEMI_CIRCLE_LEFT, colors.git_scircle, attr(attr.intensity('Bold')))
   :add_segment('git_icon', ' ' .. GLYPH_GIT_BRANCH, colors.git_bg, attr(attr.intensity('Bold')))
   :add_segment('git_text', ' ', colors.git_bg, attr(attr.intensity('Bold')))
   :add_segment('git_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.git_scircle, attr(attr.intensity('Bold')))
   -- Separator
   :add_segment('separator2', ' ' .. GLYPH_SEPARATOR .. ' ', colors.separator)
   -- Current directory
   :add_segment('dir_left', GLYPH_SEMI_CIRCLE_LEFT, colors.dir_scircle)
   :add_segment('dir_icon', ' ' .. GLYPH_FOLDER, colors.dir_bg)
   :add_segment('dir_text', ' ', colors.dir_bg)
   :add_segment('dir_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.dir_scircle)
   -- Separator
   :add_segment('separator3', ' ' .. GLYPH_SEPARATOR .. ' ', colors.separator)
   -- Số pane trong window
   :add_segment('panes_left', GLYPH_SEMI_CIRCLE_LEFT, colors.panes_scircle)
   :add_segment('panes_icon', ' ' .. GLYPH_PANES, colors.panes_bg)
   :add_segment('panes_text', ' ', colors.panes_bg, attr(attr.intensity('Bold')))
   :add_segment('panes_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.panes_scircle)

-- Cache nhánh git theo cwd. `update-right-status` chạy mỗi status_update_interval
-- (1s), mà spawn git mỗi giây thì vô ích: nhánh gần như không đổi, còn trên repo lớn
-- hoặc mount mạng thì nó chặn luôn lua thread. Cache cả kết quả âm (không phải repo)
-- để thư mục thường không bị gọi git liên tục. Đổi cwd là key đổi → cập nhật ngay.
local GIT_CACHE_TTL = 5
local git_cache = {}

---Get current git branch
---@param pane any
---@return string|nil
local function get_git_branch(pane)
   local cwd = pane:get_current_working_dir()
   if not cwd then
      return nil
   end

   local cwd_path = cwd.file_path or ''
   if cwd_path == '' then
      return nil
   end

   local now = os.time()
   local hit = git_cache[cwd_path]
   if hit and now - hit.at < GIT_CACHE_TTL then
      return hit.branch
   end

   -- run_child_process thay vì io.popen: không qua shell (thư mục có `"` hay `$(`
   -- không còn làm vỡ/inject lệnh) và không để rơi file handle chưa close.
   local ok, stdout = wezterm.run_child_process({
      'git',
      '-C',
      cwd_path,
      'branch',
      '--show-current',
   })

   local branch = nil
   if ok and stdout then
      branch = stdout:gsub('%s+$', '')
      if branch == '' then
         branch = nil
      end
   end

   git_cache[cwd_path] = { branch = branch, at = now }
   return branch
end

---Get current directory name (shortened)
---@param pane any
---@return string
local function get_current_dir(pane)
   local cwd = pane:get_current_working_dir()
   if not cwd then
      return '~'
   end

   local cwd_path = cwd.file_path or ''
   local home = os.getenv('HOME') or os.getenv('USERPROFILE') or ''

   -- Replace home with ~
   if home ~= '' then
      cwd_path = cwd_path:gsub('^' .. home, '~')
   end

   -- Get only the last directory name
   local dir_name = cwd_path:match('[^/\\]+$') or cwd_path

   -- Limit length
   if #dir_name > 20 then
      dir_name = dir_name:sub(1, 17) .. '...'
   end

   return dir_name
end

---Đếm pane: trong tab đang xem và trong toàn bộ window.
---Chỉ là các lời gọi mux trong lua, không spawn process nào → chạy mỗi giây vẫn rẻ.
---@param window any WezTerm `Window`
---@return number panes_in_tab, number panes_in_window, number tab_count
local function count_panes(window)
   local mux_win = window:mux_window()
   local active_tab_id = nil
   local active = window:active_tab()
   if active then
      active_tab_id = active:tab_id()
   end

   local in_tab, in_window, tabs = 0, 0, 0
   for _, tab in ipairs(mux_win:tabs()) do
      local n = #tab:panes()
      in_window = in_window + n
      tabs = tabs + 1
      if tab:tab_id() == active_tab_id then
         in_tab = n
      end
   end

   return in_tab, in_window, tabs
end

M.setup = function()
   wezterm.on('update-right-status', function(window, pane)
      local segments_to_render = {}

      -- Key table / Leader key indicator (highest priority)
      local key_table = window:active_key_table()
      local leader_active = window:leader_is_active()

      if key_table or leader_active then
         if leader_active then
            cells:update_segment_text('key_icon', ' ' .. GLYPH_KEY)
            cells:update_segment_text('key_text', ' LEADER ')
         else
            cells:update_segment_text('key_icon', ' ' .. GLYPH_KEY_TABLE)
            cells:update_segment_text('key_text', ' ' .. string.upper(key_table) .. ' ')
         end
         table.insert(segments_to_render, 'key_left')
         table.insert(segments_to_render, 'key_icon')
         table.insert(segments_to_render, 'key_text')
         table.insert(segments_to_render, 'key_right')
         table.insert(segments_to_render, 'separator1')
      end

      -- Git branch (secondary priority)
      local git_branch = get_git_branch(pane)
      if git_branch then
         local branch_text = git_branch
         if #branch_text > 25 then
            branch_text = branch_text:sub(1, 22) .. '...'
         end
         cells:update_segment_text('git_text', ' ' .. branch_text .. ' ')
         table.insert(segments_to_render, 'git_left')
         table.insert(segments_to_render, 'git_icon')
         table.insert(segments_to_render, 'git_text')
         table.insert(segments_to_render, 'git_right')
         table.insert(segments_to_render, 'separator2')
      end

      -- Current directory (tertiary priority)
      local dir_name = get_current_dir(pane)
      cells:update_segment_text('dir_text', ' ' .. dir_name .. ' ')
      table.insert(segments_to_render, 'dir_left')
      table.insert(segments_to_render, 'dir_icon')
      table.insert(segments_to_render, 'dir_text')
      table.insert(segments_to_render, 'dir_right')

      -- Số pane. Dạng "2/5" = pane trong tab đang xem / tổng pane trong window;
      -- window chỉ có 1 tab thì hai số trùng nhau nên chỉ hiện một số.
      local panes_in_tab, panes_in_window = count_panes(window)
      if panes_in_window > 0 then
         local panes_text = panes_in_tab == panes_in_window
            and tostring(panes_in_window)
            or (panes_in_tab .. '/' .. panes_in_window)
         cells:update_segment_text('panes_text', ' ' .. panes_text .. ' ')
         table.insert(segments_to_render, 'separator3')
         table.insert(segments_to_render, 'panes_left')
         table.insert(segments_to_render, 'panes_icon')
         table.insert(segments_to_render, 'panes_text')
         table.insert(segments_to_render, 'panes_right')
      end

      -- Render all visible segments
      if #segments_to_render > 0 then
         window:set_left_status(wezterm.format(cells:render(segments_to_render)))
      else
         window:set_left_status('')
      end
   end)
end

return M
