local Config = require('config')

require('utils.backdrops')
   -- :set_focus('#000000')
   -- :set_images_dir(require('wezterm').home_dir .. '/Pictures/Wallpapers/')
   -- Độ rõ ảnh nền: tăng opacity/brightness để ảnh rõ hơn, giảm nếu chữ khó đọc.
   -- (gốc: opacity 0.18, brightness 0.5 — chỉ nhích opacity lên một chút)
   :set_image_style({ opacity = 0.20, brightness = 0.45, saturation = 0.9 })
   :set_images()

require('events.khanhpc-theme').setup()
require('events.left-status').setup()
require('events.right-status').setup({
   date_format = '%a %H:%M:%S',
   show_cpu = false,
   show_memory = false
})
require('events.tab-title').setup({ hide_active_tab_unseen = false, unseen_icon = 'circle' })
require('events.new-tab-button').setup()
require('events.background-rotation').setup({ mode = 'cycle' }) -- or 'random'
require('events.project-backdrop').setup() -- ảnh nền theo tmux session (tiêu đề pane)
require('events.window-resized').setup()
require('events.window-state').setup()
-- `host` must be an ssh alias that resolves from ~/.ssh/config (or user@address)
require('events.remote-image-paste').setup({ host = 'macmini' })

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
