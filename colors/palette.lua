-- Nguồn sự thật duy nhất về màu cho tab bar / status bar.
--
-- Trước đây mỗi module trong events/ tự hardcode hex (`#74c7ec` xuất hiện 3 lần,
-- `#FAB387` và `#fab387` lẫn hoa/thường...), nên đổi một màu accent phải sửa 4 file.
-- Module trong events/ giờ chỉ được lấy màu từ đây, không viết hex trực tiếp.

-- stylua: ignore
local mocha = {
   rosewater = '#f5e0dc',
   flamingo  = '#f2cdcd',
   pink      = '#f5c2e7',
   mauve     = '#cba6f7',
   red       = '#f38ba8',
   maroon    = '#eba0ac',
   peach     = '#fab387',
   yellow    = '#f9e2af',
   green     = '#a6e3a1',
   teal      = '#94e2d5',
   sky       = '#89dceb',
   sapphire  = '#74c7ec',
   blue      = '#89b4fa',
   lavender  = '#b4befe',
   text      = '#cdd6f4',
   subtext1  = '#bac2de',
   subtext0  = '#a6adc8',
   overlay2  = '#9399b2',
   overlay1  = '#7f849c',
   overlay0  = '#6c7086',
   surface2  = '#585b70',
   surface1  = '#45475a',
   surface0  = '#313244',
   base      = '#1f1f28',
   mantle    = '#181825',
   crust     = '#11111b',
}

---Blend two hex colors: `t` is the weight of `fg` (0 = all `bg`, 1 = all `fg`).
---Used to derive tinted backgrounds for remote tabs without hardcoding hex.
---@param fg string '#rrggbb'
---@param bg string '#rrggbb'
---@param t number
local function mix(fg, bg, t)
   local out = '#'
   for i = 2, 6, 2 do
      local a = tonumber(fg:sub(i, i + 1), 16)
      local b = tonumber(bg:sub(i, i + 1), 16)
      out = out .. string.format('%02x', math.floor(a * t + b * (1 - t) + 0.5))
   end
   return out
end

-- Token ngữ nghĩa: đặt tên theo VAI TRÒ trong UI, không theo tên màu, để đổi theme
-- chỉ cần trỏ lại các token này sang palette khác.
-- stylua: ignore
local ui = {
   -- Nền "kính" phía sau các pill của tab/status. Nhìn thấy blur thật khi
   -- window_background_opacity < 1 + macos_window_background_blur > 0.
   glass          = 'rgba(0, 0, 0, 0.5)',

   -- Chữ trên nền accent sáng (peach/green/sapphire...)
   on_accent      = mocha.crust,
   label          = mocha.text,
   separator      = mocha.overlay0,

   -- Tab: 3 trạng thái
   tab_bg         = mocha.surface0,
   tab_fg         = mocha.subtext1,
   tab_hover_bg   = mocha.surface1,
   tab_hover_fg   = mocha.text,
   tab_active_bg  = mocha.sapphire,
   tab_active_fg  = mocha.crust,

   -- Tabs that mosh/ssh into another machine: the whole pill is recolored. Inactive and
   -- hover use an accent-tinted background, active uses the solid accent. Blue is
   -- avoided because it is too close to the sapphire of a normal active tab.
   remote_mosh          = mocha.peach,
   remote_mosh_bg       = mix(mocha.peach, mocha.base, 0.28),
   remote_mosh_hover_bg = mix(mocha.peach, mocha.base, 0.40),
   remote_ssh           = mocha.mauve,
   remote_ssh_bg        = mix(mocha.mauve, mocha.base, 0.28),
   remote_ssh_hover_bg  = mix(mocha.mauve, mocha.base, 0.40),

   -- Chỉ báo output chưa xem
   unseen         = mocha.peach,
   unseen_active  = mocha.red,

   -- Accent của từng nhóm thông tin trên status bar
   accent_key     = mocha.peach,   -- key table / LEADER
   accent_git     = mocha.green,
   accent_panes   = mocha.teal,    -- số pane trong window
   accent_cpu     = mocha.red,
   accent_mem     = mocha.mauve,
   accent_battery = mocha.yellow,
   accent_date    = mocha.sky,

   -- cwd dùng nền trầm để không cạnh tranh với accent
   dir_bg         = mocha.surface1,
   dir_fg         = mocha.text,

   -- Icon domain trong launch menu (new-tab-button)
   icon_default   = mocha.sapphire,
   icon_wsl       = mocha.peach,
   icon_ssh       = mocha.red,
   icon_unix      = mocha.green,

   -- Badge máy remote: CỐ TÌNH nằm ngoài palette Catppuccin. Đây là tín hiệu
   -- "bạn đang gõ trên máy khác", cần chói hơn mọi accent còn lại.
   alert_bg       = '#ff4444',
   alert_fg       = '#000000',
}

return { mocha = mocha, ui = ui }
