{ lib, pkgs, user, ... }:

let
  username = user.username;
  home = "/home/${username}";

  garconPath = lib.concatStringsSep ":" [
    "${home}/.local/bin"
    "${home}/.nix-profile/bin"
    "/etc/profiles/per-user/${username}/bin"
    "/run/current-system/sw/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
  ];

  garconXdgDataDirs = lib.concatStringsSep ":" [
    "${home}/.local/share"
    "${home}/.nix-profile/share"
    "/etc/profiles/per-user/${username}/share"
    "/run/current-system/sw/share"
    "/usr/local/share"
    "/usr/share"
  ];
in
{
  systemd.user.services.garcon.environment = lib.mkForce {
    PATH = garconPath;
    XDG_DATA_DIRS = garconXdgDataDirs;

    XDG_RUNTIME_DIR = lib.mkForce "/run/user/1000";
    DBUS_SESSION_BUS_ADDRESS = lib.mkForce "unix:path=/run/user/1000/bus";

    WAYLAND_DISPLAY = lib.mkForce "wayland-default";
    DISPLAY = lib.mkForce ":0";
  };
}
