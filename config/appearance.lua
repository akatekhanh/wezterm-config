local gpu_adapters = require('utils.gpu-adapter')
local backdrops = require('utils.backdrops')
local colors = require('colors.custom')
local wezterm = require('wezterm')

return {
   max_fps = 120,
   front_end = 'WebGpu',
   webgpu_power_preference = 'HighPerformance',
   webgpu_preferred_adapter = gpu_adapters:pick_best(),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Dx12', 'IntegratedGpu'),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Gl', 'Other'),
   underline_thickness = '1.5pt',

   -- cursor (SteadyBlock + no blink reduces flicker during Claude Code streaming)
   animation_fps = 1,
   cursor_blink_ease_in = 'EaseOut',
   cursor_blink_ease_out = 'EaseOut',
   default_cursor_style = 'SteadyBlock',
   cursor_blink_rate = 0,

   -- color scheme
   colors = wezterm.get_builtin_color_schemes()['Catppuccin Mocha'], -- Change to any built-in theme

   -- background
   background = backdrops:initial_options(false), -- set to true if you want wezterm to start on focus mode

   -- scrollbar
   enable_scroll_bar = false,

   -- tab bar
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = false,
   use_fancy_tab_bar = false,
   -- Đây là GIỚI HẠN TRÊN, không phải chiều rộng cố định: nhiều tab thì WezTerm tự
   -- chia nhỏ (available/num_tabs), nên nâng số này không làm giảm số tab vừa màn hình.
   -- Chỗ thật cho tiêu đề = tab_max_width - 4 (pill: 2 nửa vòng tròn + space + padding)
   -- - 2 (số thứ tự) - width badge nếu có (xem SEGMENT_WIDTH trong events/tab-title.lua).
   -- 26 → tiêu đề được 20 cột, vừa đủ cho tiêu đề tiếng Việt.
   tab_max_width = 26,
   show_tab_index_in_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

   -- window
   window_padding = {
      left = 50,
      right = 50,
      top = 50,
      bottom = 50,
   },
   initial_rows = 35,
   initial_cols = 100,
   adjust_window_size_when_changing_font_size = false,
   window_close_confirmation = 'NeverPrompt',

   -- Prevent full screen by default
   window_decorations = 'RESIZE',
   -- Nền ĐỤC. Đã thử 0.92 + blur 30 nhưng nhìn rất tệ: desktop lòi xuyên qua và chữ
   -- mất tương phản, vì backdrop chỉ là một layer ảnh ở opacity 0.18 (82% trong suốt).
   -- Giờ BackDrops:_create_opts() đã có lớp nền đục bên dưới nên nếu muốn thử lại kiểu
   -- kính mờ thì chỉ cần đổi 2 dòng dưới đây (khuyên bắt đầu từ 0.95 + blur 20):
   --    window_background_opacity = 0.95,
   --    macos_window_background_blur = 20,
   window_background_opacity = 1.0,
   window_frame = {
      active_titlebar_bg = '#090909',
      -- font = fonts.font,
      -- font_size = fonts.font_size,
   },
   -- Làm mờ pane không active để mắt biết ngay đang gõ ở đâu.
   -- Muốn tắt: đặt cả hai về 1.
   inactive_pane_hsb = {
      saturation = 0.9,
      brightness = 0.65,
   },

   visual_bell = {
      fade_in_function = 'EaseIn',
      fade_in_duration_ms = 250,
      fade_out_function = 'EaseOut',
      fade_out_duration_ms = 250,
      target = 'CursorColor',
   },
}
