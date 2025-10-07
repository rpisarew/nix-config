{ config, flake, inputs, perSystem, pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${system};
in
{
  nixpkgs.config.allowUnfree = true;
  
  imports = [
    ./hardware-configuration.nix
    flake.modules.nixos.docker
    flake.modules.nixos.ssh
    flake.modules.nixos.steam
    flake.modules.wm.hyprland
    flake.modules.gpu.amd
    # flake.modules.gpu.nvidia
    inputs.vscode-server.nixosModules.default
  ];

  # Kernel & hardware defaults
  system.stateVersion = "25.05"; # set to your installed release

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;  # keep only N generations on the ESP

  networking.hostName = "matrix";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  time.timeZone = "Europe/Berlin";

  fonts.packages = with pkgs; [
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Packages available system-wide (keep this small; prefer Home Manager for apps)
  environment.systemPackages = with pkgs; [
    pavucontrol #audio
    nemo # filemanager

    coreutils
    gnugrep
    gnutar
    gzip
    unzip
    curl
    which

    btop
    ripgrep
    git
    neovim
    wget
    wezterm

    spotify
    discord
    vscode

    dunst # notification
    libnotify

    rofi
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable the VS Code server helper
  services.vscode-server.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
  ];

  environment.sessionVariables =  {
    WLR_NO_HARDWARE_CURSORS = "1";          # common fix for wlroots+NVIDIA blank/black issues
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";   # makes Xwayland GL unambiguous
    LIBVA_DRIVER_NAME = "nvidia";           # not required for the game, avoids video/launcher oddities
    __GL_VRR_ALLOWED = "0";                 # optional: avoids some black screens on VRR displays

    # if your cursor becomes invisible
    # WLR_NO_HARDWARE_CURSORS = "1";

    # hint Electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
  };

  # Let Blueman show/authorize pairing prompts
  security.polkit.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.displayManager.sddm.enable = true;  

  # mac like keybinds
  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [ "*" ];  # required; matches all keyboards

      settings = {
        # Super (aka "meta") held:
        meta = {
          c = "C-c";  # copy
          v = "C-v";  # paste

          x = "C-x";  # cut
          z = "C-z";  # undo
          a = "C-a";  # select all
          s = "C-s";  # save
          t = "C-t";  # new tab
          # n = "C-n";  # new window (many apps)
          # q = "C-q";  # quit (works in many apps; see caution below)
          # f = "C-f";  # find
          # g = "C-g";  # find next (varies by app)
          # p = "C-p";  # print
          w = "C-w";  # close tab (⚠️ see note)
        };

        # Optional: while holding Super+Shift, use terminal-friendly shortcuts too
        "meta+shift" = {
          c = "C-S-c"; # many terminals copy with Ctrl+Shift+C
          v = "C-S-v"; # many terminals paste with Ctrl+Shift+V
        };
      };
    };
  };

  # (Optional but recommended on some systems for palm-rejection quirk with keyd’s virtual keyboard)
  # environment.etc."libinput/local-overrides.quirks".text = ''
  #   [Serial Keyboards]
  #   MatchUdevType=keyboard
  #   MatchName=keyd virtual keyboard
  #   AttrKeyboardIntegration=internal
  # '';

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  users.users = {
    # Admin
    lowm4n = {
      isNormalUser = true;
      description = "LowM4N";
      extraGroups = ["docker" "wheel" "networkmanager"];
      # shell = pkgs.bashInteractive;
      hashedPassword = "$y$j9T$zKVMZna.IIvgengXVjppm.$ZnAjitNKQssZQzuyKX413Jct2bVpRuqeHZBUAmgYy31"; # or set to "!" to lock password
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7PcPvy917XSLd/qqWUT4nHT9ML6tn/zVfbMTcAbQ9ztKGRYDLoHnKIBpIGnOJxeBQ7tHtp3r5oG3h0vatJM0+E8psJElw1Bx8iTjMD3m6bZ/l9lJmJ5tAEv8C+9n0nJ9NuzgSSbmscxutxxU8p0DpmsnIUMaByTL/1f3bB/tddOO0KFiWPKLx8bIhB0SDL6iix7dXPbvthijYj8sXkSUyNfE7jfwFHZJQz1DUg/qc9ggrrkWpvwKDPuF4kCTO2punp7VpxYAvlgYpVjK2H5qUw0dYslSoCFB3CFfd+uKFaVEgTwH36yBLspgafMQ7Df3ujBAqB/nhvRsnJ44KXZn+k9MVEcDjmjOUDTmZ1rmjWXSOrIVO+QukpCSCji9azXOBJzHe4KWziJ1dYprEYzpbVRCk67VFCZ2Y0ybmbeHzStJOGTPRXZCMzM97FwxmResEOH8Lmww3UQis7Vb0VUvVyW6RxoXb1Sbgj3C0N7HO3LwxTuga1jOZgshJ+s8ZR3JBwtrJjWHxFHClJEAUgdSHkClQ+sbL2Ii9df4e43S30dCEGVpw5HY3TYvvo7UYOEdUoYvlc9CYE+d5s+ka5bFA/Frc0YPlPojwy5CttnWKN1JM3HACx471vKufsNMTQHlspDAFtrl6rHUX6F4vMvPyC34kgR2xG4chuSzybmJcsQ== lowm4n@JARVIS.local"
      ];
    };
  };
}
