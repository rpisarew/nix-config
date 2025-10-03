{ inputs, pkgs, perSystem, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${system};
in
{
  # Home Manager basics
  home.stateVersion = "25.05"; # match your HM release

  xdg.configFile."hypr/hyprland.conf".source = "${inputs.dotfiles}/.config/hypr/hyprland.conf";
  home.file.".wezterm.lua".source = "${inputs.dotfiles}/.wezterm.lua";

  # Declarative cursor config that updates GTK & X11
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";  # or "Adwaita"
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;  # writes gtk settings
    x11.enable = true;  # sets X cursor symlink
  };

  # System-wide “prefer dark” for GNOME (and apps that read it)
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";   # GNOME 42+ dark mode flag
    gtk-theme    = "Adwaita-dark";  # optional: keep the theme name aligned
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "kvantum";
  };

  # Shell / prompt
  programs.fish = {
    enable = true;
    shellAbbrs = {
      dco = "docker-compose";
      dcu = "docker-compose up -d";
      dcd = "docker-compose down";
      dcl = "docker-compose logs";
    };
  };
  programs.bash = {
    enable = true;
    # Runs for interactive bash
    initExtra = ''
      if [[ $- == *i* ]] && [[ -z "$FISH_VERSION" ]]; then
        exec ${pkgs.fish}/bin/fish -l
      fi
    '';
  };

  home.packages =
    (with pkgs; [
      bibata-cursors
      ripgrep
      fd
      bat
    ])
    ++
    (with pkgsUnstable; [
      firefox
    ]);

  # Git defaults
  programs.git = {
    enable = true;
    userName = "Foo Bar";
    userEmail = "foo@bar.com";
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    exitShellOnExit = true;
  };

  programs.starship = {
    enable = true;
    enableInteractive = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "always";
  };

  programs.bat = {
    enable = true;
  };
}
