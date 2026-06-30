{
  workspaces = true;
  style = "auto";
  inline_height = 25;
  history_filter = [
    "ls"
    "cd"
  ];

  keymap_mode = "vim-insert";

  keymap_cursor = {
    vim_insert = "blink-bar";
    vim_normal = "steady-block";
  };

  ignored_commands = [
    "cd"
    "ls"
    "vi"
    "vim"
    "nvim"
  ];

  sync.records = true;

  theme.name = "nordic";

  ui = {
    columns = [
      {
        type = "host";
        width = 10;
      }
      {
        type = "user";
        width = 5;
      }
      "time"
      "command"
      "duration"
    ];
  };

  ai.enabled = true;
}
