{
  imports = [
    ../../../modules/system/docker.nix
    ../../../modules/system/sops.nix
  ];

  virtualisation.docker = {
    enable = true;
  };

  sops.secrets = {
    "traefik-env" = {
      format = "dotenv";
      sopsFile = ../../../secrets/docker/traefik/.env;
    };
  };

  services.dockerComposeApps = {
    "traefik" = {
      enable = true;
      composeFile = ../../../home/docker/traefik/compose.yaml;
      sopsSecretName = "traefik-env";
    };
  };
}
