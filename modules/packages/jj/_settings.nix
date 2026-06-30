{
  user = {
    name = "Cusox";
    email = "cusoxlee@gmail.com";
  };

  ui = {
    editor = "nvim";
    merge-editor = "nvimdiff";
  };

  merge-tools.nvimdiff = {
    program = "nvim";
    merge-args = [

      "-f"
      "-d"
      "$output"
      "-M"
      "$left"
      "$base"
      "$right"
      "-c"
      "wincmd J"
      "-c"
      "set modifiable"
      "-c"
      "set write"
    ];
  };

  merge-tool-edits-conflict-markers = true;
}
