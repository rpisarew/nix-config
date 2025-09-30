{ config, flake, inputs, perSystem, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  
  imports = [
    ./hardware-configuration.nix
    flake.modules.nixos.docker
    flake.modules.nixos.ssh
    inputs.vscode-server.nixosModules.default
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;  # keep only N generations on the ESP

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

  # Kernel & hardware defaults
  system.stateVersion = "24.11"; # set to your installed release

  # Packages available system-wide (keep this small; prefer Home Manager for apps)
  environment.systemPackages = with pkgs; [
    coreutils
    gnugrep
    gnutar
    gzip
    unzip
    curl
    which

    atuin
    btop
    bat
    ripgrep
    zoxide
    git
    neovim
    wget
    starship
    wezterm
    zellij

    spotify
    discord
    vscode

    pkgs.kitty # required for the default Hyprland config

    pkgs.dunst # notification
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
    pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables =  {
    # if your cursor becomes invisible
    # WLR_NO_HARDWARE_CURSORS = "1";

    # hint Electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  hardware = {
    # Enable OpenGL
    graphics.enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.waybar.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;  

  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;

  # Enable the Cinnamon Desktop Environment.
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.desktopManager.cinnamon.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb = {
  #   layout = "us";
  #   variant = "";
  # };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
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
