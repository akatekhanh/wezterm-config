-----------------------------------------------------------------------------------
-- Bridge the local clipboard image into a session running on a remote machine.  --
--                                                                              --
-- SSH does not forward the clipboard, so an app running over SSH (Claude Code,  --
-- for example) can never see an image copied on this machine. This grabs the    --
-- image, copies it to the remote host, and types the remote path into the pane  --
-- so the remote app can read it from disk instead.                              --
-----------------------------------------------------------------------------------

local wezterm = require('wezterm')

local M = {}

-- Absolute path on purpose. WezTerm is a GUI app, so its PATH is the launchd
-- default (/usr/bin:/bin:/usr/sbin:/sbin) and does NOT include Homebrew.
-- Spawning a bare 'pngpaste' fails silently here.
local PNGPASTE = '/opt/homebrew/bin/pngpaste'
local SSH = '/usr/bin/ssh'
local SCP = '/usr/bin/scp'

-- BatchMode makes ssh/scp fail fast instead of blocking on a password prompt
-- that cannot be seen or answered from inside this callback. Without it a host
-- needing a password would freeze the UI, since run_child_process is blocking.
local SSH_OPTS = { '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=5' }

---@param window any WezTerm Window
---@param msg string
local function notify(window, msg)
   window:toast_notification('WezTerm', msg, nil, 5000)
end

---Build an argv list as `cmd + SSH_OPTS + varargs`
---@param cmd string
---@return string[]
local function ssh_argv(cmd, ...)
   local argv = { cmd }
   for _, opt in ipairs(SSH_OPTS) do
      table.insert(argv, opt)
   end
   for _, arg in ipairs({ ... }) do
      table.insert(argv, arg)
   end
   return argv
end

---@alias Event.RemoteImagePasteOptions { host: string, remote_dir: string? }

---@param opts Event.RemoteImagePasteOptions
M.setup = function(opts)
   opts = opts or {}
   local host = opts.host
   assert(
      type(host) == 'string' and host ~= '',
      'remote-image-paste.setup: `host` is required (an ssh alias or user@address)'
   )
   local remote_dir = opts.remote_dir or '/tmp/wezterm-clipboard'

   wezterm.on('remote.paste-image', function(window, pane)
      local stamp = os.date('!%Y%m%dT%H%M%S') .. '-' .. tostring(math.random(1000, 9999))
      local local_path = '/tmp/wezterm-clip-' .. stamp .. '.png'
      local remote_path = remote_dir .. '/clip-' .. stamp .. '.png'

      -- pngpaste exits non-zero when the clipboard holds no image
      local ok, _, err = wezterm.run_child_process({ PNGPASTE, local_path })
      if not ok then
         notify(window, 'Clipboard không có ảnh')
         wezterm.log_warn('remote.paste-image: pngpaste failed: ' .. (err or ''))
         return
      end

      ok, _, err = wezterm.run_child_process(ssh_argv(SSH, host, 'mkdir -p ' .. remote_dir))
      if not ok then
         os.remove(local_path)
         notify(window, 'Không ssh được tới ' .. host)
         wezterm.log_error('remote.paste-image: ssh failed: ' .. (err or ''))
         return
      end

      ok, _, err = wezterm.run_child_process(ssh_argv(SCP, local_path, host .. ':' .. remote_path))
      os.remove(local_path)
      if not ok then
         notify(window, 'scp thất bại')
         wezterm.log_error('remote.paste-image: scp failed: ' .. (err or ''))
         return
      end

      -- Trailing space so the next typed word does not glue onto the path
      pane:send_text(remote_path .. ' ')
   end)
end

return M
