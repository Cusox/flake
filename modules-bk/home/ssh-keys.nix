let
  sshKeys = import ../../config/ssh/keys.nix;
in
{
  home.file.".ssh/authorized_keys".text =
    builtins.concatStringsSep "\n" (builtins.attrValues sshKeys) + "\n";
}
