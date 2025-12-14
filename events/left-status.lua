local wezterm = require('wezterm')
local Cells = require('utils.cells')

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
local GLYPH_SEPARATOR = nf.ple_left_half_circle_thin --[[ '' ]]

---@type table<string, Cells.SegmentColors>
-- Enhanced color system with better hierarchy
local colors = {
   -- Key table colors (highest priority - warm accent)
   key_bg = { bg = '#fab387', fg = '#1c1b19' },
   key_scircle = { bg = 'rgba(0, 0, 0, 0.5)', fg = '#fab387' },

   -- Git branch colors (secondary - cool accent)
   git_bg = { bg = '#a6e3a1', fg = '#1c1b19' },
   git_scircle = { bg = 'rgba(0, 0, 0, 0.5)', fg = '#a6e3a1' },

   -- Directory colors (tertiary - muted)
   dir_bg = { bg = '#45475a', fg = '#cdd6f4' },
   dir_scircle = { bg = 'rgba(0, 0, 0, 0.5)', fg = '#45475a' },

   -- Separator
   separator = { bg = 'rgba(0, 0, 0, 0.5)', fg = '#6c7086' },
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

---Get current git branch
---@param pane any
---@return string|nil
local function get_git_branch(pane)
   local cwd = pane:get_current_working_dir()
   if not cwd then
      return nil
   end

   local cwd_path = cwd.file_path or ''
   local success, stdout = pcall(function()
      return io.popen('cd "' .. cwd_path .. '" 2>/dev/null && git branch --show-current 2>/dev/null'):read('*a')
   end)

   if success and stdout and stdout ~= '' then
      return stdout:gsub('%s+', '')
   end
   return nil
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

      -- Render all visible segments
      if #segments_to_render > 0 then
         window:set_left_status(wezterm.format(cells:render(segments_to_render)))
      else
         window:set_left_status('')
      end
   end)
end

return M
