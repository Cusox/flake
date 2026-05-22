{ user, ... }:

let
  username = user.username;
  homeDir = "/home/${username}";
in
{
  sops.secrets.ssh_private_config = {
    sopsFile = ../../config/ssh/config.yaml;
    key = "private_config";
    path = "/home/${username}/.ssh/conf.d/private";
    owner = username;
    group = "users";
    mode = "0600";
  };

  system.activationScripts.ensureSshConfDir.text = ''
    mkdir -p ${homeDir}/.ssh/conf.d
    chmod 700 ${homeDir}/.ssh ${homeDir}/.ssh/conf.d
    chown ${username}:users ${homeDir}/.ssh ${homeDir}/.ssh/conf.d
  '';
}
