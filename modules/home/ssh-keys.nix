let
  sshKeys = import ../../config/ssh/keys.nix;
in
{
  home.file.".ssh/authorizedKeys".text =
    builtins.concatStringsSep "\n" (builtins.attrValues sshKeys) + "\n";
}
