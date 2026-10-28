-- Tính độ rộng tab có tính đến left/right status.
--
-- WezTerm (20240203, wezterm-gui/src/tabbar.rs `TabBarState::new`) chia độ rộng tab
-- theo công thức:
--    available = cột_cửa_sổ - (số_tab - 1) - nút_new_tab
--    tab_width = min(tab_max_width, available / số_tab)
-- và KHÔNG trừ left status lẫn right status. Left status của config này (cwd + số
-- pane) chiếm ~15 cột nên trên màn hình nhỏ, tab vẫn được cấp full width rồi đẩy
-- nút `+` và right status ra ngoài mép (right status bị cắt từ trái sang).
--
-- Module này là state dùng chung: left/right-status ghi lại độ rộng thật của mình,
-- window-resized / update-status ghi lại số cột của tab bar, còn tab-title hỏi
-- `fit()` để biết mỗi tab thực sự được bao nhiêu cột.

local wezterm = require('wezterm')

local M = {}

-- Không cho tab hẹp hơn mức này: pill (4) + số thứ tự (2) + ~6 ký tự tiêu đề.
-- Hẹp hơn nữa thì thà để right status bị cắt (wezterm tự cắt) còn hơn tab vô nghĩa.
M.MIN_TAB_WIDTH = 12

-- `tab_bar_style.new_tab` mặc định là ' + ' (3 cột). Config không đổi style này.
M.NEW_TAB_BUTTON_WIDTH = 3

local state = {
   bar_cols = nil, -- số cột của toàn tab bar (= pixel_width cửa sổ / cell width)
   left_cols = 0,
   right_cols = 0,
}

---Độ rộng (cột) của một mảng FormatItem — chỉ tính các item `{ Text = ... }`.
---@param items FormatItem[]
---@return number
function M.items_width(items)
   local w = 0
   for _, item in ipairs(items) do
      if type(item) == 'table' and item.Text then
         w = w + wezterm.column_width(item.Text)
      end
   end
   return w
end

---@param items FormatItem[]
function M.set_left(items)
   state.left_cols = M.items_width(items)
end

---@param items FormatItem[]
function M.set_right(items)
   state.right_cols = M.items_width(items)
end

---Đặt thẳng số cột tab bar (dùng cho test / debug; bình thường dùng update_from_window).
---@param cols number
function M.set_bar_cols(cols)
   state.bar_cols = cols
end

---Ghi lại số cột của tab bar từ GUI window. Tab bar trải hết chiều rộng cửa sổ (kể
---cả window_padding) nên không dùng thẳng `cols` của pane; suy cell width từ kích
---thước tab đang active rồi chia pixel_width của cửa sổ.
---@param window any WezTerm GUI `Window`
function M.update_from_window(window)
   local ok, err = pcall(function()
      local dims = window:get_dimensions()
      local tab = window:active_tab()
      if not dims or not tab then
         return
      end
      local size = tab:get_size()
      if not size or not size.cols or size.cols == 0 or not size.pixel_width then
         return
      end
      local cell_w = size.pixel_width / size.cols
      if cell_w <= 0 then
         return
      end
      state.bar_cols = math.floor(dims.pixel_width / cell_w)
   end)
   if not ok then
      wezterm.log_warn('tabbar-layout: ' .. tostring(err))
   end
end

-- Left status tối thiểu phải còn chỗ cho pill số pane ( 󰕰 1/3 ) ≈ 9 cột.
M.LEFT_MIN_WIDTH = 10

---Độ rộng cho mỗi tab. CỐ ĐỊNH theo (số cột tab bar, số tab, right status), KHÔNG phụ
---thuộc left status: left status đổi theo tab đang active (git branch, tên thư mục)
---nên nếu chia theo nó thì mỗi lần chuyển tab cả dãy tab lại co giãn, nhìn không
---đồng nhất. Thay vào đó left status phải tự cắt để vừa phần còn lại (xem left_budget).
---@param max_width number giá trị wezterm đưa vào format-tab-title (đã bị nó cắt bớt)
---@param tab_max_width number config.tab_max_width
---@param num_tabs number
---@return number
function M.fit(max_width, tab_max_width, num_tabs)
   if not state.bar_cols or num_tabs < 1 then
      return max_width
   end
   local usable = state.bar_cols - state.right_cols - M.NEW_TAB_BUTTON_WIDTH - M.LEFT_MIN_WIDTH
   local per_tab = math.floor(usable / num_tabs)
   if per_tab < M.MIN_TAB_WIDTH then
      per_tab = M.MIN_TAB_WIDTH
   end
   if per_tab > tab_max_width then
      per_tab = tab_max_width
   end
   -- wezterm cắt cứng dòng dài hơn max_width của nó, nên không được vượt.
   if per_tab > max_width then
      per_tab = max_width
   end
   return per_tab
end

---Số cột left status được phép chiếm sau khi đã dành chỗ cho tab + nút + right status.
---@param tab_max_width number config.tab_max_width
---@param num_tabs number
---@return number|nil nil khi chưa biết kích thước cửa sổ (không giới hạn)
function M.left_budget(tab_max_width, num_tabs)
   if not state.bar_cols or num_tabs < 1 then
      return nil
   end
   local tab_w = M.fit(tab_max_width, tab_max_width, num_tabs)
   local budget = state.bar_cols - state.right_cols - M.NEW_TAB_BUTTON_WIDTH - tab_w * num_tabs
   if budget < M.LEFT_MIN_WIDTH then
      budget = M.LEFT_MIN_WIDTH
   end
   return budget
end

---Chỉ để debug: `wezterm.log_info(layout.debug())`
function M.debug()
   return string.format(
      'bar=%s left=%d right=%d',
      tostring(state.bar_cols),
      state.left_cols,
      state.right_cols
   )
end

return M
