{ config, ... }:

{
  programs.ssh.includes = [
    "~/.ssh/conf.d/*"
  ];

  sops.secrets.ssh_private_config = {
    sopsFile = ../../config/ssh/config.yaml;
    key = "private_config";
    path = "${config.home.homeDirectory}/.ssh/conf.d/private";
    mode = "0600";
  };

  home.activation.ensureSSHConfDir = ''
    mkdir -p "$HOME/.ssh/conf.d"
    chmod 700 "$HOME/.ssh"
    chmod 700 "$HOME/.ssh/conf.d"
  '';
}
