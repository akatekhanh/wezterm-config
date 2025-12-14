local wezterm = require('wezterm')
local umath = require('utils.math')
local Cells = require('utils.cells')
local OptsValidator = require('utils.opts-validator')

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
-- Enhanced color system with visual hierarchy
-- stylua: ignore
local colors = {
   -- CPU (high priority - performance indicator)
   cpu        = { fg = '#f38ba8', bg = 'rgba(0, 0, 0, 0.5)' },
   cpu_circle = { fg = '#f38ba8', bg = 'rgba(0, 0, 0, 0.5)' },

   -- Memory (medium-high priority)
   memory        = { fg = '#cba6f7', bg = 'rgba(0, 0, 0, 0.5)' },
   memory_circle = { fg = '#cba6f7', bg = 'rgba(0, 0, 0, 0.5)' },

   -- Battery (medium priority)
   battery        = { fg = '#f9e2af', bg = 'rgba(0, 0, 0, 0.5)' },
   battery_circle = { fg = '#f9e2af', bg = 'rgba(0, 0, 0, 0.5)' },

   -- Date/Time (standard priority)
   date        = { fg = '#89dceb', bg = 'rgba(0, 0, 0, 0.5)' },
   date_circle = { fg = '#89dceb', bg = 'rgba(0, 0, 0, 0.5)' },

   -- Separators
   separator = { fg = '#6c7086', bg = 'rgba(0, 0, 0, 0.5)' }
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

---Get CPU usage percentage (cross-platform)
---@return string|nil
local function get_cpu_usage()
   local platform = require('utils.platform')
   local success, result

   if platform.is_mac or platform.is_linux then
      success, result = pcall(function()
         local handle = io.popen("top -l 1 | grep 'CPU usage' | awk '{print $3}' | sed 's/%//' 2>/dev/null || ps -A -o %cpu | awk '{s+=$1} END {print s}'")
         if handle then
            local output = handle:read('*a')
            handle:close()
            return output
         end
         return nil
      end)
   elseif platform.is_win then
      success, result = pcall(function()
         local handle = io.popen('wmic cpu get loadpercentage /value 2>nul')
         if handle then
            local output = handle:read('*a')
            handle:close()
            return output:match('LoadPercentage=(%d+)')
         end
         return nil
      end)
   end

   if success and result and result ~= '' then
      local cpu = tonumber(result:gsub('%s+', ''))
      if cpu then
         return string.format('%d%%', math.floor(cpu))
      end
   end
   return nil
end

---Get memory usage (cross-platform)
---@return string|nil
local function get_memory_usage()
   local platform = require('utils.platform')
   local success, result

   if platform.is_mac then
      success, result = pcall(function()
         local handle = io.popen("memory_pressure | grep 'System-wide memory free percentage:' | awk '{print 100-$5}' 2>/dev/null")
         if handle then
            local output = handle:read('*a')
            handle:close()
            return output
         end
         return nil
      end)
   elseif platform.is_linux then
      success, result = pcall(function()
         local handle = io.popen("free | grep Mem | awk '{print ($3/$2) * 100.0}'")
         if handle then
            local output = handle:read('*a')
            handle:close()
            return output
         end
         return nil
      end)
   elseif platform.is_win then
      success, result = pcall(function()
         local handle =
            io.popen('wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value 2>nul')
         if handle then
            local output = handle:read('*a')
            handle:close()
            local free = output:match('FreePhysicalMemory=(%d+)')
            local total = output:match('TotalVisibleMemorySize=(%d+)')
            if free and total then
               local used_percent = ((tonumber(total) - tonumber(free)) / tonumber(total)) * 100
               return tostring(used_percent)
            end
         end
         return nil
      end)
   end

   if success and result and result ~= '' then
      local mem = tonumber(result:gsub('%s+', ''))
      if mem then
         return string.format('%d%%', math.floor(mem))
      end
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
