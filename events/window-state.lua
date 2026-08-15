local wezterm = require 'wezterm'

local M = {}

-- Fullscreen thì cho trong suốt nhẹ. Đặt = nil nếu muốn fullscreen cũng đục hẳn.
local FULLSCREEN_OPACITY = nil

function M.setup()
  wezterm.on('window-state-changed', function(window, pane)
    local dims = window:get_dimensions()
    local overrides = window:get_config_overrides() or {}

    -- KHÔNG hardcode giá trị cho trạng thái không-fullscreen: gán nil để xoá override,
    -- window quay về dùng window_background_opacity trong config/appearance.lua.
    -- Bản cũ luôn ép 1.0 khi không fullscreen, nên mọi thiết lập opacity ở appearance.lua
    -- đều bị vô hiệu ở trạng thái thường và chỉ có tác dụng khi fullscreen — rất khó hiểu.
    overrides.window_background_opacity = dims.is_fullscreen and FULLSCREEN_OPACITY or nil

    window:set_config_overrides(overrides)
  end)
end

return M
