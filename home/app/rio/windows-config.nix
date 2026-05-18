{ pkgs, lib, ... }:

let
  settings = import ./settings.nix pkgs;

  tomlFormat = pkgs.formats.toml { };

  configToml = tomlFormat.generate "rio-config.toml" settings;

  windowsUser = "cusox";
  windowsRioDir = "/mnt/c/Users/${windowsUser}/AppData/Local/rio";
in
{
  home.activation.syncRioConfigToWindows = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${windowsRioDir}/themes"

    cp ${configToml} "${windowsRioDir}/config.toml"
    cp ${./nordic.toml} "${windowsRioDir}/themes/nordic.toml"
  '';
}
