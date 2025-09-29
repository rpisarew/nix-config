{ pkgs, ... }:
{
  # Home Manager basics
  home.stateVersion = "24.11"; # match your HM release

  # Terminal app: Alacritty
  # programs.alacritty = {
  #   enable = true;
  #   # Example settings (Alacritty 0.13+ uses TOML; HM writes the right format)
  #   settings = {
  #     window = { opacity = 0.96; };
  #     font = { size = 12.0; };
  #     cursor = { style = "Beam"; };
  #   };
  # };

  # Shell / prompt
  programs.fish.enable = true;
  programs.starship.enable = true;

  # Useful CLI apps (user-scoped)
  home.packages = with pkgs; [ ripgrep fd bat ];

  # Git defaults
  programs.git = {
    enable = true;
    userName = "Foo Bar";
    userEmail = "foo@bar.com";
  };

  # SSH client config (optional tweaks)
  programs.ssh = {
    enable = true;
    matchBlocks."*".extraOptions = {
      ServerAliveInterval = "30";
      ServerAliveCountMax = "3";
    };
  };
}
