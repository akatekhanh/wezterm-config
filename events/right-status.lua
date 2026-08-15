local wezterm = require('wezterm')
local umath = require('utils.math')
local Cells = require('utils.cells')
local OptsValidator = require('utils.opts-validator')
local ui = require('colors.palette').ui

---@alias Event.RightStatusOptions { date_format?: string, show_cpu?: boolean, show_memory?: boolean }

---Setup options for the right status bar
local EVENT_OPTS = {}

---@type OptsSchema
EVENT_OPTS.schema = {
   {
      name = 'date_format',
      type = 'string',
      default = '%a %H:%M:%S',
   },
   {
      name = 'show_cpu',
      type = 'boolean',
      default = true,
   },
   {
      name = 'show_memory',
      type = 'boolean',
      default = true,
   },
}
EVENT_OPTS.validator = OptsValidator:new(EVENT_OPTS.schema)

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

-- Enhanced iconography
local ICON_SEPARATOR = nf.ple_left_half_circle_thin --[[ '' ]]
local ICON_DATE = nf.fa_calendar --[[ '' ]]
local ICON_CPU = nf.md_chip --[[ '󰘚' ]]
local ICON_MEMORY = nf.md_memory --[[ '󰍛' ]]
local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]

---@type string[]
local discharging_icons = {
   nf.md_battery_10,
   nf.md_battery_20,
   nf.md_battery_30,
   nf.md_battery_40,
   nf.md_battery_50,
   nf.md_battery_60,
   nf.md_battery_70,
   nf.md_battery_80,
   nf.md_battery_90,
   nf.md_battery,
}
---@type string[]
local charging_icons = {
   nf.md_battery_charging_10,
   nf.md_battery_charging_20,
   nf.md_battery_charging_30,
   nf.md_battery_charging_40,
   nf.md_battery_charging_50,
   nf.md_battery_charging_60,
   nf.md_battery_charging_70,
   nf.md_battery_charging_80,
   nf.md_battery_charging_90,
   nf.md_battery_charging,
}

---@type table<string, Cells.SegmentColors>
-- Màu lấy từ colors/palette.lua — không hardcode hex ở đây.
-- stylua: ignore
local colors = {
   cpu           = { fg = ui.accent_cpu,     bg = ui.glass },
   cpu_circle    = { fg = ui.accent_cpu,     bg = ui.glass },

   memory        = { fg = ui.accent_mem,     bg = ui.glass },
   memory_circle = { fg = ui.accent_mem,     bg = ui.glass },

   battery       = { fg = ui.accent_battery, bg = ui.glass },
   battery_circle= { fg = ui.accent_battery, bg = ui.glass },

   date          = { fg = ui.accent_date,    bg = ui.glass },
   date_circle   = { fg = ui.accent_date,    bg = ui.glass },

   separator     = { fg = ui.separator,      bg = ui.glass },
}

local cells = Cells:new()

-- Initialize all segments
cells
   -- CPU
   :add_segment('cpu_left', GLYPH_SEMI_CIRCLE_LEFT, colors.cpu_circle, attr(attr.intensity('Bold')))
   :add_segment('cpu_icon', ' ' .. ICON_CPU, colors.cpu, attr(attr.intensity('Bold')))
   :add_segment('cpu_text', '', colors.cpu, attr(attr.intensity('Bold')))
   :add_segment('cpu_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.cpu_circle, attr(attr.intensity('Bold')))
   -- Separator
   :add_segment('separator1', ' ' .. ICON_SEPARATOR .. ' ', colors.separator)
   -- Memory
   :add_segment('memory_left', GLYPH_SEMI_CIRCLE_LEFT, colors.memory_circle, attr(attr.intensity('Bold')))
   :add_segment('memory_icon', ' ' .. ICON_MEMORY, colors.memory, attr(attr.intensity('Bold')))
   :add_segment('memory_text', '', colors.memory, attr(attr.intensity('Bold')))
   :add_segment('memory_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.memory_circle, attr(attr.intensity('Bold')))
   -- Separator
   :add_segment('separator2', ' ' .. ICON_SEPARATOR .. ' ', colors.separator)
   -- Battery
   :add_segment('battery_left', GLYPH_SEMI_CIRCLE_LEFT, colors.battery_circle)
   :add_segment('battery_icon', '', colors.battery)
   :add_segment('battery_text', '', colors.battery, attr(attr.intensity('Bold')))
   :add_segment('battery_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.battery_circle)
   -- Separator
   :add_segment('separator3', ' ' .. ICON_SEPARATOR .. ' ', colors.separator)
   -- Date/Time
   :add_segment('date_left', GLYPH_SEMI_CIRCLE_LEFT, colors.date_circle)
   :add_segment('date_icon', ' ' .. ICON_DATE, colors.date)
   :add_segment('date_text', '', colors.date, attr(attr.intensity('Bold')))
   :add_segment('date_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.date_circle)

---@return string, string
local function battery_info()
   -- ref: https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html

   local charge = ''
   local icon = ''

   for _, b in ipairs(wezterm.battery_info()) do
      local idx = umath.clamp(umath.round(b.state_of_charge * 10), 1, 10)
      charge = string.format('%.0f%%', b.state_of_charge * 100)

      if b.state == 'Charging' then
         icon = charging_icons[idx]
      else
         icon = discharging_icons[idx]
      end
   end

   return charge, icon .. ' '
end

-- Cache cho các chỉ số hệ thống. `update-right-status` chạy mỗi giây, mà đo hệ thống
-- bằng io.popen là ĐỒNG BỘ: nó chặn lua thread đúng bằng thời gian lệnh chạy.
-- Bản cũ gọi `top -l 1` (đo được 0,69s/lần!) mỗi giây → chặn ~70% thời gian.
local METRIC_TTL = 5
local metric_cache = {}

---Đọc chỉ số có cache, dùng run_child_process (không qua shell, không rơi file handle)
---@param key string
---@param argv string[]
---@param parse fun(stdout: string): string|nil
---@return string|nil
local function cached_metric(key, argv, parse)
   local now = os.time()
   local hit = metric_cache[key]
   if hit and now - hit.at < METRIC_TTL then
      return hit.value
   end

   local value = nil
   local ok, stdout = wezterm.run_child_process(argv)
   if ok and stdout then
      local parsed_ok, parsed = pcall(parse, stdout)
      if parsed_ok then
         value = parsed
      end
   end

   metric_cache[key] = { value = value, at = now }
   return value
end

---Tải hệ thống (load average 1 phút), KHÔNG phải %CPU tức thời.
---Đây là đánh đổi có chủ ý: `sysctl -n vm.loadavg` mất 0,002s, còn cách duy nhất lấy
---%CPU tức thời trên macOS (`top -l 1`) mất 0,69s và sẽ chặn UI mỗi giây.
---@return string|nil
local function get_cpu_usage()
   local platform = require('utils.platform')

   if platform.is_mac then
      return cached_metric('load', { 'sysctl', '-n', 'vm.loadavg' }, function(out)
         -- dạng: "{ 5.89 5.89 6.06 }"
         local one_min = out:match('{%s*([%d%.]+)')
         return one_min and string.format('%.2f', tonumber(one_min)) or nil
      end)
   elseif platform.is_linux then
      return cached_metric('load', { 'cat', '/proc/loadavg' }, function(out)
         local one_min = out:match('^([%d%.]+)')
         return one_min and string.format('%.2f', tonumber(one_min)) or nil
      end)
   elseif platform.is_win then
      return cached_metric(
         'load',
         { 'wmic', 'cpu', 'get', 'loadpercentage', '/value' },
         function(out)
            local pct = out:match('LoadPercentage=(%d+)')
            return pct and (pct .. '%') or nil
         end
      )
   end

   return nil
end

---Phần trăm RAM đang dùng (có cache, không qua shell)
---@return string|nil
local function get_memory_usage()
   local platform = require('utils.platform')

   if platform.is_mac then
      return cached_metric('mem', { 'memory_pressure' }, function(out)
         -- dạng: "System-wide memory free percentage: 40%"
         local free = out:match('System%-wide memory free percentage:%s*(%d+)')
         return free and string.format('%d%%', 100 - tonumber(free)) or nil
      end)
   elseif platform.is_linux then
      return cached_metric('mem', { 'free' }, function(out)
         local total, used = out:match('Mem:%s+(%d+)%s+(%d+)')
         if total and tonumber(total) > 0 then
            return string.format('%d%%', math.floor(used / total * 100))
         end
         return nil
      end)
   elseif platform.is_win then
      return cached_metric('mem', {
         'wmic',
         'OS',
         'get',
         'FreePhysicalMemory,TotalVisibleMemorySize',
         '/Value',
      }, function(out)
         local free = out:match('FreePhysicalMemory=(%d+)')
         local total = out:match('TotalVisibleMemorySize=(%d+)')
         if free and total and tonumber(total) > 0 then
            return string.format('%d%%', math.floor((total - free) / total * 100))
         end
         return nil
      end)
   end

   return nil
end

---@param opts? Event.RightStatusOptions Default: {date_format = '%a %H:%M:%S', show_cpu = true, show_memory = true}
M.setup = function(opts)
   local valid_opts, err = EVENT_OPTS.validator:validate(opts or {})

   if err then
      wezterm.log_error(err)
   end

   wezterm.on('update-right-status', function(window, _pane)
      local segments_to_render = {}

      -- CPU usage
      if valid_opts.show_cpu then
         local cpu = get_cpu_usage()
         if cpu then
            cells:update_segment_text('cpu_text', ' ' .. cpu .. ' ')
            table.insert(segments_to_render, 'cpu_left')
            table.insert(segments_to_render, 'cpu_icon')
            table.insert(segments_to_render, 'cpu_text')
            table.insert(segments_to_render, 'cpu_right')
            table.insert(segments_to_render, 'separator1')
         end
      end

      -- Memory usage
      if valid_opts.show_memory then
         local memory = get_memory_usage()
         if memory then
            cells:update_segment_text('memory_text', ' ' .. memory .. ' ')
            table.insert(segments_to_render, 'memory_left')
            table.insert(segments_to_render, 'memory_icon')
            table.insert(segments_to_render, 'memory_text')
            table.insert(segments_to_render, 'memory_right')
            table.insert(segments_to_render, 'separator2')
         end
      end

      -- Battery info
      local battery_text, battery_icon = battery_info()
      if battery_text ~= '' then
         cells:update_segment_text('battery_icon', ' ' .. battery_icon)
         cells:update_segment_text('battery_text', battery_text .. ' ')
         table.insert(segments_to_render, 'battery_left')
         table.insert(segments_to_render, 'battery_icon')
         table.insert(segments_to_render, 'battery_text')
         table.insert(segments_to_render, 'battery_right')
         table.insert(segments_to_render, 'separator3')
      end

      -- Date/Time (always shown)
      cells:update_segment_text('date_text', ' ' .. wezterm.strftime(valid_opts.date_format) .. ' ')
      table.insert(segments_to_render, 'date_left')
      table.insert(segments_to_render, 'date_icon')
      table.insert(segments_to_render, 'date_text')
      table.insert(segments_to_render, 'date_right')

      -- Render
      window:set_right_status(wezterm.format(cells:render(segments_to_render)))
   end)
end

return M
