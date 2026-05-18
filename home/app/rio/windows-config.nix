{ pkgs, lib, ... }:

let
  settings = import ./settings.nix {
    inherit pkgs;
    target = "windows";
  };

  tomlFormat = pkgs.formats.toml { };

  configToml = tomlFormat.generate "rio-config.toml" settings;

  windowsUser = "cusox";
  windowsRioDir = "/mnt/c/Users/${windowsUser}/AppData/Local/rio";
in
{
  home.activation.syncRioConfigToWindows = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${windowsRioDir}/themes"

    rm -f "${windowsRioDir}/config.toml"
    rm -f "${windowsRioDir}/themes/nordic.toml"

    cp ${configToml} "${windowsRioDir}/config.toml"
    cp ${./nordic.toml} "${windowsRioDir}/themes/nordic.toml"
  '';
}
