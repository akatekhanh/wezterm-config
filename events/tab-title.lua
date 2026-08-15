------------------------------------------------------------------------------------------
-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614 --
------------------------------------------------------------------------------------------

local wezterm = require('wezterm')
local Cells = require('utils.cells')
local OptsValidator = require('utils.opts-validator')
local ui = require('colors.palette').ui

---
-- =======================================
-- Defining event setup options and schema
-- =======================================

---@alias Event.TabTitleOptions { unseen_icon: 'circle' | 'numbered_circle' | 'numbered_box', hide_active_tab_unseen: boolean }

---Setup options for the tab title
local EVENT_OPTS = {}

---@type OptsSchema
EVENT_OPTS.schema = {
   {
      name = 'unseen_icon',
      type = 'string',
      enum = { 'circle', 'numbered_circle', 'numbered_box' },
      default = 'circle',
   },
   {
      name = 'hide_active_tab_unseen',
      type = 'boolean',
      default = true,
   },
}
EVENT_OPTS.validator = OptsValidator:new(EVENT_OPTS.schema)

---
-- ===================
-- Constants and icons
-- ===================

local nf = wezterm.nerdfonts

local M = {}

local GLYPH_SCIRCLE_LEFT = nf.ple_left_half_circle_thick --[[  ]]
local GLYPH_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[  ]]
local GLYPH_CIRCLE = nf.fa_circle --[[  ]]
local GLYPH_ADMIN = nf.md_shield_half_full --[[ 󰞀 ]]
local GLYPH_LINUX = nf.cod_terminal_linux --[[  ]]
local GLYPH_DEBUG = nf.fa_bug --[[  ]]
-- Dùng glyph Nerd Font, KHÔNG dùng emoji: '🖥️' (U+1F5A5 U+FE0F) được wezterm tính là
-- 1 cell nhưng vẽ rộng 15.6px trong cell 10px (kiểm tra: wezterm ls-fonts --text ...),
-- nên nó tràn sang ô kế bên → tab chồng chữ. Glyph Nerd Font có x_adv=10, cells=1.
local GLYPH_KHANHPC = nf.md_monitor
-- local GLYPH_SEARCH = nf.fa_search --[[  ]]
local GLYPH_SEARCH = nf.md_magnify
local KHANHPC_LABEL = 'KhanhPC'

-- Tên process dạng chữ ăn 5-6 cột ('zsh ~ ', 'node ~ ') trong ~21 cột khả dụng, nên
-- tiêu đề tiếng Việt luôn bị cắt. Process hay dùng đổi thành 1 glyph; process lạ vẫn
-- hiện tên chữ để không mất thông tin (phần toán chiều rộng đã tính theo cột nên
-- độ rộng thay đổi không còn gây tràn).
-- stylua: ignore
local PROCESS_ICONS = {
   zsh      = nf.md_console,
   bash     = nf.md_console,
   sh       = nf.md_console,
   fish     = nf.md_console,
   tmux     = nf.cod_terminal_tmux,
   node     = nf.md_nodejs,
   claude   = nf.md_robot,
   ssh      = nf.md_ssh,
   mosh     = nf.md_ssh,
   ['mosh-client'] = nf.md_ssh,
   python   = nf.md_language_python,
   python3  = nf.md_language_python,
   git      = nf.dev_git,
   lazygit  = nf.dev_git,
   nvim     = nf.custom_vim,
   vim      = nf.custom_vim,
   docker   = nf.md_docker,
   kubectl  = nf.md_kubernetes,
   psql     = nf.md_database,
   duckdb   = nf.md_database,
   top      = nf.md_chart_areaspline,
   htop     = nf.md_chart_areaspline,
   btop     = nf.md_chart_areaspline,
}

local GLYPH_UNSEEN_NUMBERED_BOX = {
   [1] = nf.md_numeric_1_box_multiple, --[[ 󰼏 ]]
   [2] = nf.md_numeric_2_box_multiple, --[[ 󰼐 ]]
   [3] = nf.md_numeric_3_box_multiple, --[[ 󰼑 ]]
   [4] = nf.md_numeric_4_box_multiple, --[[ 󰼒 ]]
   [5] = nf.md_numeric_5_box_multiple, --[[ 󰼓 ]]
   [6] = nf.md_numeric_6_box_multiple, --[[ 󰼔 ]]
   [7] = nf.md_numeric_7_box_multiple, --[[ 󰼕 ]]
   [8] = nf.md_numeric_8_box_multiple, --[[ 󰼖 ]]
   [9] = nf.md_numeric_9_box_multiple, --[[ 󰼗 ]]
   [10] = nf.md_numeric_9_plus_box_multiple, --[[ 󰼘 ]]
}

local GLYPH_UNSEEN_NUMBERED_CIRCLE = {
   [1] = nf.md_numeric_1_circle, --[[ 󰲠 ]]
   [2] = nf.md_numeric_2_circle, --[[ 󰲢 ]]
   [3] = nf.md_numeric_3_circle, --[[ 󰲤 ]]
   [4] = nf.md_numeric_4_circle, --[[ 󰲦 ]]
   [5] = nf.md_numeric_5_circle, --[[ 󰲨 ]]
   [6] = nf.md_numeric_6_circle, --[[ 󰲪 ]]
   [7] = nf.md_numeric_7_circle, --[[ 󰲬 ]]
   [8] = nf.md_numeric_8_circle, --[[ 󰲮 ]]
   [9] = nf.md_numeric_9_circle, --[[ 󰲰 ]]
   [10] = nf.md_numeric_9_plus_circle, --[[ 󰲲 ]]
}

-- Chiều rộng hiển thị (số cột) của từng segment KHÔNG phải title, để tính chính xác
-- phần còn lại cho title. Phải khớp với Tab:create_cells() — sửa một bên thì sửa cả hai.
local SEGMENT_WIDTH = {
   scircle_left = 1,
   scircle_right = 1,
   padding = 1,
   title_lead = 1, -- khoảng trắng đứng trước title trong segment 'title'
   admin = 2, -- ' ' + icon
   wsl = 2, -- ' ' + icon
   khanhpc = 2 + #KHANHPC_LABEL, -- ' ' + icon + nhãn
   unseen_output = 2, -- ' ' + icon
}

local TITLE_INSET_BASE = SEGMENT_WIDTH.scircle_left
   + SEGMENT_WIDTH.title_lead
   + SEGMENT_WIDTH.padding
   + SEGMENT_WIDTH.scircle_right

local RENDER_VARIANTS = {
   { 'scircle_left', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'title', 'unseen_output', 'padding', 'scircle_right' },
   { 'scircle_left', 'admin', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'admin', 'title', 'unseen_output', 'padding', 'scircle_right' },
   { 'scircle_left', 'wsl', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'wsl', 'title', 'unseen_output', 'padding', 'scircle_right' },
   { 'scircle_left', 'khanhpc', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'khanhpc', 'title', 'unseen_output', 'padding', 'scircle_right' },
}


---@type table<string, Cells.SegmentColors>
-- Màu lấy từ colors/palette.lua — không hardcode hex ở đây.
-- stylua: ignore
local colors = {
   text_default          = { bg = ui.tab_bg,        fg = ui.tab_fg },
   text_hover            = { bg = ui.tab_hover_bg,  fg = ui.tab_hover_fg },
   text_active           = { bg = ui.tab_active_bg, fg = ui.tab_active_fg },

   unseen_output_default = { bg = ui.tab_bg,        fg = ui.unseen },
   unseen_output_hover   = { bg = ui.tab_hover_bg,  fg = ui.unseen },
   unseen_output_active  = { bg = ui.tab_active_bg, fg = ui.unseen_active },

   -- Nửa vòng tròn hai đầu pill: fg = màu thân pill, bg = nền kính
   scircle_default       = { bg = ui.glass, fg = ui.tab_bg },
   scircle_hover         = { bg = ui.glass, fg = ui.tab_hover_bg },
   scircle_active        = { bg = ui.glass, fg = ui.tab_active_bg },
}

---
-- ================
-- Helper functions
-- ================

---@param proc string
local function clean_process_name(proc)
   local a = string.gsub(proc, '(.*[/\\])(.*)', '%2')
   return a:gsub('%.exe$', '')
end

---@param process_name string
---@param base_title string
---@param max_width number
---@param inset number
---@param tab_index number? 1-based tab number, rendered as an iTerm2-style prefix
local function create_title(process_name, base_title, max_width, inset, tab_index)
   local title

   if process_name:len() > 0 then
      local icon = PROCESS_ICONS[process_name]
      title = (icon or process_name .. ' ~') .. ' ' .. base_title
   else
      title = base_title
   end

   if base_title == 'Debug' then
      title = GLYPH_DEBUG .. ' DEBUG'
   end

   if base_title:match('^InputSelector:') ~= nil then
      title = base_title:gsub('InputSelector:', GLYPH_SEARCH .. ' ')
   end

   -- The index prefix eats into the available width, so charge it to `inset`
   -- before the truncate/pad math to keep the rendered width at max_width.
   local prefix = tab_index ~= nil and (tostring(tab_index) .. ' ') or ''

   -- Đo bằng SỐ CỘT hiển thị, không phải số byte. Tiêu đề tiếng Việt ('à', 'ệ' = 2 byte)
   -- hay glyph Nerd Font (3 byte) làm `:len()` đếm dư → cắt lố, pad thiếu, và `:sub()`
   -- còn có thể cắt giữa một ký tự UTF-8 làm hỏng luôn glyph.
   local avail = max_width - inset - wezterm.column_width(prefix)
   if avail < 1 then
      avail = 1
   end

   return prefix .. wezterm.pad_right(wezterm.truncate_right(title, avail), avail)
end

---@param panes any[] WezTerm https://wezfurlong.org/wezterm/config/lua/pane/index.html
local function check_unseen_output(panes)
   local unseen_output = false
   local unseen_output_count = 0

   for i = 1, #panes, 1 do
      if panes[i].has_unseen_output then
         unseen_output = true
         if unseen_output_count >= 10 then
            unseen_output_count = 10
            break
         end
         unseen_output_count = unseen_output_count + 1
      end
   end

   return unseen_output, unseen_output_count
end

---
-- =================
-- Tab class and API
-- =================

---@class Tab
---@field title string
---@field cells Cells
---@field title_locked boolean
---@field locked_title string
---@field is_wsl boolean
---@field is_admin boolean
---@field is_khanhpc boolean
---@field unseen_output boolean
---@field unseen_output_count number
---@field is_active boolean
local Tab = {}
Tab.__index = Tab

function Tab:new()
   local tab = {
      title = '',
      cells = Cells:new(),
      title_locked = false,
      locked_title = '',
      is_wsl = false,
      is_admin = false,
      is_khanhpc = false,
      unseen_output = false,
      unseen_output_count = 0,
   }
   return setmetatable(tab, self)
end

---Segment icon đang dùng cho tab này, hoặc nil nếu là tab thường.
---Dùng chung cho cả phần tính inset (set_info) và phần chọn render variant (render)
---để hai chỗ không bao giờ lệch nhau — đó chính là lỗi làm tab KhanhPC tràn width.
---@return 'khanhpc'|'wsl'|'admin'|nil
function Tab:icon_segment()
   if self.is_khanhpc then
      return 'khanhpc'
   end
   if self.is_wsl then
      return 'wsl'
   end
   if self.is_admin then
      return 'admin'
   end
   return nil
end

---@param event_opts Event.TabTitleOptions
---@param tab any WezTerm https://wezfurlong.org/wezterm/config/lua/MuxTab/index.html
---@param max_width number
function Tab:set_info(event_opts, tab, max_width)
   local process_name = clean_process_name(tab.active_pane.foreground_process_name)
   -- `tab.active_pane` trong event này là PaneInformation, KHÔNG phải Pane:
   -- nó chỉ có field `domain_name`, không có method `get_domain_name()`.
   -- Gọi sai method làm cả handler throw → wezterm bỏ toàn bộ theme tab và
   -- rơi về tab bar mặc định (log cũ có 30k lần lỗi này).
   local domain_name = tab.active_pane.domain_name or ''
   local pane_title = tab.active_pane.title or ''

   self.is_wsl = process_name:match('^wsl') ~= nil
   self.is_admin = (
      pane_title:match('^Administrator: ') or pane_title:match('(Admin)')
   ) ~= nil
   -- Detect khanhpc by domain name or pane title
   self.is_khanhpc = (
      domain_name == 'khanhpc' or
      pane_title:match('khanhpc') or
      pane_title:match('akatekhanh@') or
      pane_title:match('100%.69%.140%.48')
   ) ~= nil
   self.unseen_output = false
   self.unseen_output_count = 0

   if not event_opts.hide_active_tab_unseen or not tab.is_active then
      self.unseen_output, self.unseen_output_count = check_unseen_output(tab.panes)
   end

   local inset = TITLE_INSET_BASE
   local icon = self:icon_segment()
   if icon then
      inset = inset + SEGMENT_WIDTH[icon]
   end
   if self.unseen_output then
      inset = inset + SEGMENT_WIDTH.unseen_output
   end

   local tab_index = tab.tab_index + 1

   if self.title_locked then
      self.title = create_title('', self.locked_title, max_width, inset, tab_index)
      return
   end
   self.title = create_title(process_name, pane_title, max_width, inset, tab_index)
end

function Tab:create_cells()
   local attr = self.cells.attr
   self.cells
      :add_segment('scircle_left', GLYPH_SCIRCLE_LEFT)
      :add_segment('admin', ' ' .. GLYPH_ADMIN)
      :add_segment('wsl', ' ' .. GLYPH_LINUX)
      :add_segment('khanhpc', ' ' .. GLYPH_KHANHPC .. KHANHPC_LABEL)
      :add_segment('title', ' ', nil, attr(attr.intensity('Bold')))
      :add_segment('unseen_output', ' ' .. GLYPH_CIRCLE)
      :add_segment('padding', ' ')
      :add_segment('scircle_right', GLYPH_SCIRCLE_RIGHT)
end

---@param title string
function Tab:update_and_lock_title(title)
   self.locked_title = title
   self.title_locked = true
end

---@param event_opts Event.TabTitleOptions
---@param is_active boolean
---@param hover boolean
function Tab:update_cells(event_opts, is_active, hover)
   local tab_state = 'default'
   if is_active then
      tab_state = 'active'
   elseif hover then
      tab_state = 'hover'
   end

   self.cells:update_segment_text('title', ' ' .. self.title)

   if event_opts.unseen_icon == 'numbered_box' and self.unseen_output then
      self.cells:update_segment_text(
         'unseen_output',
         ' ' .. GLYPH_UNSEEN_NUMBERED_BOX[self.unseen_output_count]
      )
   end
   if event_opts.unseen_icon == 'numbered_circle' and self.unseen_output then
      self.cells:update_segment_text(
         'unseen_output',
         ' ' .. GLYPH_UNSEEN_NUMBERED_CIRCLE[self.unseen_output_count]
      )
   end

   self.cells
      :update_segment_colors('scircle_left', colors['scircle_' .. tab_state])
      :update_segment_colors('admin', colors['text_' .. tab_state])
      :update_segment_colors('wsl', colors['text_' .. tab_state])
      :update_segment_colors('khanhpc', { bg = ui.alert_bg, fg = ui.alert_fg })
      :update_segment_colors('title', colors['text_' .. tab_state])
      :update_segment_colors('unseen_output', colors['unseen_output_' .. tab_state])
      :update_segment_colors('padding', colors['text_' .. tab_state])
      :update_segment_colors('scircle_right', colors['scircle_' .. tab_state])
end

---@return FormatItem[] (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)
function Tab:render()
   local icon = self:icon_segment()
   local variant_idx = 1
   if icon == 'admin' then
      variant_idx = 3
   elseif icon == 'wsl' then
      variant_idx = 5
   elseif icon == 'khanhpc' then
      variant_idx = 7
   end

   if self.unseen_output then
      variant_idx = variant_idx + 1
   end
   return self.cells:render(RENDER_VARIANTS[variant_idx])
end

---@type Tab[]
local tab_list = {}

---@param opts? Event.TabTitleOptions Default: {unseen_icon = 'circle', hide_active_tab_unseen = true}
M.setup = function(opts)
   local valid_opts, err = EVENT_OPTS.validator:validate(opts or {})

   if err then
      wezterm.log_error(err)
   end

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   -- Tab name will remain locked until the `reset-tab-title` is triggered
   wezterm.on('tabs.manual-update-tab-title', function(window, pane)
      window:perform_action(
         wezterm.action.PromptInputLine({
            description = wezterm.format({
               { Foreground = { Color = ui.label } },
               { Attribute = { Intensity = 'Bold' } },
               { Text = 'Enter new name for tab' },
            }),
            action = wezterm.action_callback(function(_window, _pane, line)
               if line ~= nil then
                  local tab = window:active_tab()
                  local id = tab:tab_id()
                  tab_list[id]:update_and_lock_title(line)
               end
            end),
         }),
         pane
      )
   end)

   -- CUSTOM EVENT
   -- Event listener to unlock manually set tab name
   wezterm.on('tabs.reset-tab-title', function(window, _pane)
      local tab = window:active_tab()
      local id = tab:tab_id()
      tab_list[id].title_locked = false
   end)

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   wezterm.on('tabs.toggle-tab-bar', function(window, _pane)
      local effective_config = window:effective_config()
      window:set_config_overrides({
         enable_tab_bar = not effective_config.enable_tab_bar,
         background = effective_config.background,
      })
   end)

   -- BUILTIN EVENT
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
      if not tab_list[tab.tab_id] then
         tab_list[tab.tab_id] = Tab:new()
         tab_list[tab.tab_id]:set_info(valid_opts, tab, max_width)
         tab_list[tab.tab_id]:create_cells()
         return tab_list[tab.tab_id]:render()
      end

      tab_list[tab.tab_id]:set_info(valid_opts, tab, max_width)
      tab_list[tab.tab_id]:update_cells(valid_opts, tab.is_active, hover)
      return tab_list[tab.tab_id]:render()
   end)
end

return M
