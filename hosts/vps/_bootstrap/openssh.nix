{ lib, hostConfig, ... }:

{
  services.openssh = {
    enable = true;
    ports = [
      hostConfig.ssh.port
    ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkForce "prohibit-password";
    };
  };
}
