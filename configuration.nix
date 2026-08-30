{ config, pkgs, ... }:

{
  # =========================================================================
  # 1. Módulos e Importaciones
  # =========================================================================
  imports = [
    ./hardware-configuration.nix
    ./modules/system-apps.nix
    ./modules/virtualisation.nix
  ];

  # =========================================================================
  # 2. Arranque y Kernel (Bootloader)
  # =========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # =========================================================================
  # 3. Red y Conectividad
  # =========================================================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # =========================================================================
  # 4. Localización e Idioma
  # =========================================================================
  time.timeZone = "America/Argentina/Buenos_Aires";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # =========================================================================
  # 5. Entorno Gráfico y Teclado
  # =========================================================================
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Distribución del teclado en X11 y consola TTY
  services.xserver.xkb = {
    layout = "latam";
    variant = "deadtilde";
  };
  console.keyMap = "la-latin1";

  # =========================================================================
  # 6. Hardware y Periféricos
  # =========================================================================
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Name = "Hello";
        ControllerMode = "dual";
        FastConnectable = "true";
        Experimental = "true";
      };
      Policy = {
        AutoEnable = "true";
      };
    };
  };

  hardware.opentabletdriver.enable = true;

  # =========================================================================
  # 7. Audio e Impresión
  # =========================================================================
  services.printing.enable = true;

  # Configuración de audio con PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # =========================================================================
  # 8. Usuarios del Sistema
  # =========================================================================
  users.users."gabrields" = {
    isNormalUser = true;
    description = "Gabriel da Silva";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
    packages = with pkgs; [ ];
  };

  # =========================================================================
  # 9. Integración del Sistema
  # =========================================================================
  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "alacritty.desktop"
      ];
    };
  };

  # =========================================================================
  # 10. Fuentes Tipográficas
  # =========================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # =========================================================================
  # 11. Configuración de Nix y Mantenimiento
  # =========================================================================
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Limpieza periódica del Nix Store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # =========================================================================
  # 12. Versión del Estado de NixOS
  # =========================================================================
  system.stateVersion = "26.05";
}
