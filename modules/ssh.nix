{
  flake.modules = {
    homeManager.ssh = { config, ... }: {
      sops.secrets.ssh_config = {
        sopsFile = ../secrets/ssh.yaml;
        key = "config";
      };

      programs.ssh = {
        enable = true;

        enableDefaultConfig = false;

        includes = [
          config.sops.secrets.ssh_config.path
        ];

        settings = {
          "*" = {
            ForwardAgent = false;
            AddKeysToAgent = "no";
            Compression = false;
            ServerAliveInterval = 60;
            ServerAliveCountMax = 3;
            HashKnownHosts = true;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "auto";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "30m";
            SetEnv = {
              TERM = "xterm-256color";
            };
          };
        };
      };
    };
  };
}
