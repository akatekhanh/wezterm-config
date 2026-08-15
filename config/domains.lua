return {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   -- ssh_domains = {},
   ssh_domains = {
      -- yazi's image preview on Windows will only work if launched via ssh from WSL
      {
         name = 'wsl.ssh',
         remote_address = 'localhost',
         multiplexing = 'None',
         default_prog = { 'zsh', '-l' },
         assume_shell = 'Posix'
      },
      -- khanhpc - Red color scheme when connected
      {
         name = 'khanhpc',
         remote_address = '100.69.140.48',
         username = 'akatekhanh',
      }
   },

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {
      {
         name = 'WSL:Ubuntu',
         distribution = 'Ubuntu',
         username = 'kevin',
         default_cwd = '/home/kevin',
         default_prog = { 'zsh', '-l' },
      },
   },
}
