return {
   -- behaviours
   automatically_reload_config = true,
   exit_behavior = 'CloseOnCleanExit', -- if the shell program exited with a successful status
   exit_behavior_messaging = 'Verbose',
   status_update_interval = 1000,

   scrollback_lines = 50000,

   -- Thêm vào mẫu mặc định của QuickSelect (URL, đường dẫn, git hash, IP, UUID...)
   quick_select_patterns = {
      '\\b(?:s3a?|gs|abfss?)://\\S+', -- đường dẫn object storage
      '\\barn:[\\w-]+:[\\w-]+:[\\w-]*:\\d*:\\S+', -- AWS ARN
   },

   hyperlink_rules = {
      -- Matches: a URL in parens: (URL)
      {
         regex = '\\((\\w+://\\S+)\\)',
         format = '$1',
         highlight = 1,
      },
      -- Matches: a URL in brackets: [URL]
      {
         regex = '\\[(\\w+://\\S+)\\]',
         format = '$1',
         highlight = 1,
      },
      -- Matches: a URL in curly braces: {URL}
      {
         regex = '\\{(\\w+://\\S+)\\}',
         format = '$1',
         highlight = 1,
      },
      -- Matches: a URL in angle brackets: <URL>
      {
         regex = '<(\\w+://\\S+)>',
         format = '$1',
         highlight = 1,
      },
      -- Then handle URLs not wrapped in brackets
      {
         regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
         format = '$0',
      },
      -- cổng dev server in ra không có scheme: localhost:3000/docs
      {
         regex = '\\b(?:localhost|127\\.0\\.0\\.1):\\d+(?:/\\S*)?',
         format = 'http://$0',
      },
      -- implicit mailto link
      {
         regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b',
         format = 'mailto:$0',
      },
   },
}
