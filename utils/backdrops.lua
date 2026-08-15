local wezterm = require('wezterm')
local colors = require('colors.custom')

-- Seeding random numbers before generating for use
-- Known issue with lua math library
-- see: https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
math.randomseed(os.time())
math.random()
math.random()
math.random()

local GLOB_PATTERN = '*.{jpg,jpeg,png,gif,bmp,ico,tiff,pnm,dds,tga}'

---@class BackDrops
---@field current_idx number index of current image
---@field images string[] background images
---@field images_dir string directory of background images. Default is `wezterm.config_dir .. '/backdrops/'`
---@field focus_color string background color when in focus mode. Default is `colors.custom.background`
---@field focus_on boolean focus mode on or off
local BackDrops = {}
BackDrops.__index = BackDrops

--- Initialise backdrop controller
---@private
function BackDrops:init()
   local inital = {
      current_idx = 1,
      images = {},
      images_dir = wezterm.config_dir .. '/backdrops/',
      focus_color = colors.background,
      focus_on = false,
   }
   local backdrops = setmetatable(inital, self)
   return backdrops
end

---Override the default `images_dir`
---Default `images_dir` is `wezterm.config_dir .. '/backdrops/'`
---
--- INFO:
---  This function must be invoked before `set_images()`
---
---@param path string directory of background images
function BackDrops:set_images_dir(path)
   self.images_dir = path
   if not path:match('/$') then
      self.images_dir = path .. '/'
   end
   return self
end

---MUST BE RUN BEFORE ALL OTHER `BackDrops` functions
---Sets the `images` after instantiating `BackDrops`.
---
--- INFO:
---   During the initial load of the config, this function can only invoked in `wezterm.lua`.
---   WezTerm's fs utility `glob` (used in this function) works by running on a spawned child process.
---   This throws a coroutine error if the function is invoked in outside of `wezterm.lua` in the -
---   initial load of the Terminal config.
function BackDrops:set_images()
   self.images = wezterm.glob(self.images_dir .. GLOB_PATTERN)

   -- Find totoro.jpeg and set it as default
   for idx, file in ipairs(self.images) do
      if file:match('totoro%.jpeg$') or file:match('totoro%.jpg$') then
         self.current_idx = idx
         break
      end
   end

   return self
end

---Override the default `focus_color`
---Default `focus_color` is `colors.custom.background`
---@param focus_color string background color when in focus mode
function BackDrops:set_focus(focus_color)
   self.focus_color = focus_color
   return self
end

---Lớp nền ĐỤC nằm dưới ảnh.
---Không có lớp này thì background chỉ gồm ảnh ở opacity 0.18, tức 82% trong suốt:
---hạ window_background_opacity xuống dưới 1 là desktop lòi xuyên qua terminal và chữ
---mất tương phản. Có lớp này thì độ trong suốt do window_background_opacity quyết định
---một cách đồng đều, và ảnh vẫn giữ nguyên mức mờ 0.18 so với nền.
---@private
---@return table
function BackDrops:_base_layer()
   return {
      source = { Color = colors.background },
      width = '100%',
      height = '100%',
      opacity = 1,
   }
end

---Create the `background` options with the current image
---@private
---@return table
function BackDrops:_create_opts()
   -- Không có ảnh nào (thư mục backdrops rỗng, hoặc wezterm.glob() không chạy được
   -- ngoài GUI) thì chỉ trả lớp nền đục. Nếu vẫn tạo layer ảnh thì source thành
   -- `{ File = nil }` = bảng rỗng, và wezterm báo "Expected a valid BackgroundSource".
   if not self.images[self.current_idx] then
      return { self:_base_layer() }
   end

   return {
      self:_base_layer(),
      {
         source = { File = self.images[self.current_idx] },
         horizontal_align = 'Center',
         vertical_align = 'Middle',
         -- 'Cover' keeps the aspect ratio and crops the overflow.
         -- '100%' stretches the image to the window, which distorts any
         -- backdrop whose aspect ratio differs from the window's.
         width = 'Cover',
         height = 'Cover',
         repeat_x = 'NoRepeat',
         repeat_y = 'NoRepeat',
         -- Dimmed so bright backdrops don't fight with text/diff highlights
         hsb = { brightness = 0.5, hue = 1.0, saturation = 0.9 },
         opacity = 0.18,
      },
   }
end

---Create the `background` options for focus mode
---@private
---@return table
function BackDrops:_create_focus_opts()
   return {
      {
         source = { Color = self.focus_color },
         height = '120%',
         width = '120%',
         vertical_offset = '-10%',
         horizontal_offset = '-10%',
         opacity = 1,
      },
   }
end

---Background options ứng với trạng thái hiện tại (focus mode hay ảnh).
---MỌI nơi cần đặt lại background phải dùng hàm này, đừng tự viết lại bảng layer —
---trước đây events/window-resized.lua tự định nghĩa một bản khác (100% thay vì Cover,
---opacity 0.3, không có hsb dimming) nên background nhảy sang bản sáng hơn và bị méo
---tỉ lệ mỗi lần window resize.
---@return table
function BackDrops:current_options()
   if self.focus_on then
      return self:_create_focus_opts()
   end
   return self:_create_opts()
end

---Set the initial options for `background`
---@param focus_on boolean? focus mode on or off
function BackDrops:initial_options(focus_on)
   focus_on = focus_on or false
   assert(type(focus_on) == 'boolean', 'BackDrops:initial_options - Expected a boolean')

   self.focus_on = focus_on
   return self:current_options()
end

---Override the current window options for background
---@private
---@param window any WezTerm Window see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param background_opts table background option
function BackDrops:_set_opt(window, background_opts)
   local effective = window:effective_config()
   window:set_config_overrides({
      background = background_opts,
      enable_tab_bar = effective.enable_tab_bar,
      window_background_opacity = effective.window_background_opacity,
   })
end

---Override the current window options for background with focus color
---@private
---@param window any WezTerm Window see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:_set_focus_opt(window)
   local effective = window:effective_config()
   local opts = {
      background = {
         {
            source = { Color = self.focus_color },
            height = '120%',
            width = '120%',
            vertical_offset = '-10%',
            horizontal_offset = '-10%',
            opacity = 1,
         },
      },
      enable_tab_bar = effective.enable_tab_bar,
      window_background_opacity = effective.window_background_opacity,
   }
   window:set_config_overrides(opts)
end

---Convert the `files` array to a table of `InputSelector` choices
---see: https://wezfurlong.org/wezterm/config/lua/keyassignment/InputSelector.html
function BackDrops:choices()
   local choices = {}
   for idx, file in ipairs(self.images) do
      table.insert(choices, {
         id = tostring(idx),
         label = file:match('([^/]+)$'),
      })
   end
   return choices
end

---Select a random background from the loaded `files`
---Pass in `Window` object to override the current window options
---@param window any? WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:random(window)
   self.current_idx = math.random(#self.images)

   if window ~= nil then
      self:_set_opt(window, self:_create_opts())
   end
end

---Cycle the loaded `files` and select the next background
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_forward(window)
   if self.current_idx == #self.images then
      self.current_idx = 1
   else
      self.current_idx = self.current_idx + 1
   end
   self:_set_opt(window, self:_create_opts())
end

---Cycle the loaded `files` and select the previous background
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_back(window)
   if self.current_idx == 1 then
      self.current_idx = #self.images
   else
      self.current_idx = self.current_idx - 1
   end
   self:_set_opt(window, self:_create_opts())
end

---Set a specific background from the `files` array
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param idx number index of the `files` array
function BackDrops:set_img(window, idx)
   if idx > #self.images or idx < 0 then
      wezterm.log_error('Index out of range')
      return
   end

   self.current_idx = idx
   self:_set_opt(window, self:_create_opts())
end

---Toggle the focus mode
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:toggle_focus(window)
   local background_opts

   if self.focus_on then
      background_opts = self:_create_opts()
      self.focus_on = false
   else
      background_opts = self:_create_focus_opts()
      self.focus_on = true
   end

   self:_set_opt(window, background_opts)
end

return BackDrops:init()
