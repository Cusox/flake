{ lib, ... }:

let
  hosts = import ../../../config/hosts.nix;
  sshHosts = lib.filterAttrs (_name: host: host ? ssh) hosts;

  mkSSHSettings =
    name: host:
    {
      HostName = host.ssh.hostname;
      User = host.ssh.user;
      IdentityFile = host.ssh.identityFile or "~/.ssh/id_ed25519";
      IdentitiesOnly = true;
    }
    // lib.optionalAttrs (host.ssh ? port) {
      Port = host.ssh.port;
    }
    // lib.optionalAttrs (host.ssh ? proxyJump) {
      ProxyJump = host.ssh.proxyJump;
    };
in
{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    includes = [
      "~/.ssh/conf.d/*"
    ];

    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    }
    // lib.mapAttrs mkSSHSettings sshHosts;
  };

  home.activation.ensureSSHConfDir = ''
    mkdir -p "$HOME/.ssh/conf.d"
    chmod 700 "$HOME/.ssh"
  '';
}
