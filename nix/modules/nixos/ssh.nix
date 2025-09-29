{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
    ports = [ 22 ];
  };
  networking.firewall.allowedTCPPorts = [ 22 ];
}
