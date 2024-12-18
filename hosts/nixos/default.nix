{ config, inputs, lib, pkgs, nix-vscode-extensions, agenix, ... }:

let
  user = "james";
  keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p" ];
in

{
  imports = [
    ../../modules/nixos/secrets.nix
    ../../modules/nixos/disk-config.nix
    ../../modules/nixos/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    agenix.nixosModules.default
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "xhci_pci" "uhci_hcd" "ehci_pci" "ahci" "nvme" "usbhid" "usb_storage" "virtio_scsi" "virtio_pci" "sd_mod" "sr_mod" ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "uinput" "amdgpu" "kvm-intel" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance"; # powersave

  time.timeZone = "Australia/Brisbane";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "nixos";
    useDHCP = false;
    interfaces."enp6s18".useDHCP = true;
    firewall.enable = false;
  };

  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings.allowed-users = [ "${user}" ];
    settings.auto-optimise-store = true;
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes auto-allocate-uids
    '';
  };

  # Manages keys and such
  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # Fish Shell
    fish.enable = true;

    hyprland = {
      enable = true;

      xwayland = {
        # hidpi = true;
        enable = true;
      };
    };
  };

  # Gaming
  hardware.steam-hardware.enable = true;
  services.ratbagd.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];

      displayManager = {
        gdm.enable = true;
        gdm.wayland = true;
        defaultSession = "hyprland";
        # autoLogin = {
        #   enable = true;
        #   user = "james";
        # };
      };

      layout = "us";
      xkbOptions = "ctrl:nocaps"; # Turn Caps Lock into Ctrl
      libinput.enable = true;
    };

    openssh.enable = true;
    fstrim.enable = true;
    qemuGuest.enable = true;

    # Sync state between machines
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/${user}/.local/share/syncthing";
      configDir = "/home/${user}/.config/syncthing";
      user = "${user}";
      group = "users";
      guiAddress = "127.0.0.1:8384";
      overrideFolders = true;
      overrideDevices = true;

      settings = {
        devices = { };
        options.globalAnnounceEnabled = false; # Only sync on LAN
      };
    };

    dbus.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    printing.enable = true;
    printing.drivers = [ pkgs.brlaser ];
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   jack.enable = true;
  # };

  hardware = {
    enableRedistributableFirmware = lib.mkDefault true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        rocmPackages.clr.icd
        amdvlk
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
      setLdLibraryPath = true;
    };
    xone.enable = true;
    ledger.enable = true;
  };

  # Add docker daemon
  virtualisation.docker.enable = true;
  virtualisation.docker.logDriver = "json-file";

  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  fonts.packages = with pkgs; [
    dejavu_fonts
    emacs-all-the-icons-fonts
    feather-font # from overlay
    jetbrains-mono
    liberation_ttf
    fira-code
    fira-code-symbols
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    dina-font
    proggyfonts
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  environment.systemPackages = with pkgs; [
    agenix.packages."${pkgs.system}".default # "x86_64-linux"
    gitAndTools.gitFull
    inetutils
    nano
    wget
    curl
    libvirt
    lm_sensors
    clinfo
    glmark2
    wineWowPackages.waylandFull
    lutris
    playonlinux
    bottles
    heroic
    piper
    prismlauncher
    jdk17
    jdk11
    jdk8
    corectrl
  ];

  system.stateVersion = "21.05"; # Don't change this
}
