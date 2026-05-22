{ config, ... }:

{
  sops.secrets.ssh_private_config = {
    sopsFile = ../../config/ssh/config.yaml;
    key = "private_config";
    path = "${config.home.homeDirectory}/.ssh/conf.d/private";
    mode = "0600";
  };
}
