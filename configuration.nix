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
  boot.loader.systemd-boot.configurationLimit = 10; # Mantener las últimas 10 generaciones en el menú
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # Usar la versión más reciente del kernel Linux

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

  # Compositor Wayland Hyprland a nivel de sistema
  programs.hyprland.enable = true;

  # Distribución del teclado en entorno gráfico y consola TTY
  services.xserver.xkb = {
    layout = "latam";
    variant = "deadtilde";
  };
  console.keyMap = "la-latin1";

  # =========================================================================
  # 6. Hardware y Periféricos
  # =========================================================================
  # Bluetooth y soporte de gestión
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

  services.blueman.enable = true;

  # Soporte para tabletas gráficas (OpenTabletDriver)
  hardware.opentabletdriver.enable = true;

  # =========================================================================
  # 7. Audio e Impresión
  # =========================================================================
  # Servicio de impresión CUPS
  services.printing.enable = true;

  # Servidor de audio PipeWire (reemplaza PulseAudio con compatibilidad ALSA/Pulse)
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
  };

  # =========================================================================
  # 9. Integración del Sistema
  # =========================================================================
  # Definición de terminal predeterminada para el estándar XDG
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
  # Permitir paquetes privativos/propietarios
  nixpkgs.config.allowUnfree = true;

  # Habilitar soporte para Flakes y el comando moderno 'nix'
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Recolección periódica de basura del Nix Store
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
