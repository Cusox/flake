let
  users = import ../users.nix;
  user = users.vcs;
in

{
  user = {
    name = user.username;
    email = user.useremail;
  };

  credential.helper = [
    "cache --timeout 21600"
  ];

  column.ui = "auto";

  branch.sort = "-committerdate";

  tag.sort = "version:refname";

  init.defaultBranch = "main";

  diff = {
    algorithm = "histogram";
    colorMoved = "plain";
    mnemonicPrefix = true;
    renames = true;
  };

  push = {
    default = "simple";
    autoSetupRemote = true;
    followTags = true;
  };

  fetch = {
    prune = true;
    pruneTags = true;
    all = true;
  };

  help.autocorrect = "prompt";

  pull.rebase = true;

  include.path = "~/.config/delta/themes/nordic.gitconfig";

  merge.tool = "nvimdiff";

  mergetool = {
    keepBackup = false;
    conflictstyle = "zdiff3";
    nvimdiff = {
      layout = "LOCAL,BASE,REMOTE / MERGED";
    };
  };
}
