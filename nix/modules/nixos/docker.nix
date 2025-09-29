# { config, lib, pkgs, ... }:

# {
#   options."my-custom-module".enable = lib.mkEnableOption "My custom feature";

#   config = lib.mkIf config."my-custom-module".enable {
#     environment.systemPackages = [ pkgs.hello ];
#   };
# }

{ ... }:
{
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
