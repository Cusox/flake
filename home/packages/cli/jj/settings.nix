let
  users = import ../../../../config/users.nix;
  user = users.vcs;
in
{
  user = {
    name = user.username;
    email = user.useremail;
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
