{ config, pkgs, inputs, ... }:

{
  # =========================================================================
  # 1. Módulos de Usuario
  # =========================================================================
  imports = [
    ./modules/neovim.nix
  ];

  # =========================================================================
  # 2. Identidad y Directorio de Usuario
  # =========================================================================
  home.username = "gabrields";
  home.homeDirectory = "/home/gabrields";

  # =========================================================================
  # 3. Paquetes Declarativos del Usuario
  # =========================================================================
  home.packages = with pkgs; [
    # Terminal y Herramientas de Consola
    tmux
    fzf
    ripgrep
    pyright
    marksman
    brightnessctl

    # Lanzador y Portapapeles
    fuzzel
    clipse

    # Capturas y Grabación de Pantalla
    grim
    slurp
    swappy
    wf-recorder

    # Barra de Estado
    ashell

    # Notificaciones
    mako

    # Cliente Bluetooth
    overskride

    # Ecosistema Oficial Hypr
    hyprpaper
    hyprlock
    hypridle
    hyprsunset

    # Editores de Texto e IDEs
    zed-editor

    # Comunicación
    discord
    telegram-desktop
    signal-desktop

    # Desarrollo y Productividad
    obsidian
    rnote
    qalculate-qt
    texliveFull

    # Pizarra de dibujo (AppImage empaquetado con Nix)
    (pkgs.callPackage ./modules/excalidraw-desktop.nix {})

    # Utilidades
    qbittorrent

    # IDE oficial y CLI desde el Flake externo Antigravity
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-ide
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-cli
  ];

  # =========================================================================
  # 4. Programas y Herramientas CLI / GUI
  # =========================================================================
  # Control de versiones con Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        userName = "gabyds01";
        userEmail = "gabyingds01@gmail.com";
      };
    };
  };

  # Emulador de terminal Kitty
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12.0;
    };
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };

  # Navegador Web Firefox
  programs.firefox.enable = true;

  # Gestión de entornos por directorio con integración Nix
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Shell Bash y atajos personalizados
  programs.bash = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/dotfiles";
    };
  };

  services.mako.enable = true;
  services.hypridle.enable = true;  # Levanta la gestión de inactividad
  services.hyprpaper.enable = true; # Levanta el gestor de fondos de pantalla

  systemd.user.services = {
    # Servicio para el portapapeles Clipse
    clipse = {
      Unit = {
        Description = "Daemon de portapapeles Clipse";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.clipse}/bin/clipse -listen";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  
    # Servicio para el filtro de luz azul Hyprsunset
    hyprsunset = {
      Unit = {
        Description = "Filtro de luz azul Hyprsunset";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  
    # Servicio para la barra de estado ashell
    ashell = {
      Unit = {
        Description = "Barra de estado ashell";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.ashell}/bin/ashell";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # =========================================================================
  # 5. Gestor de Ventanas (Wayland / Hyprland)
  # =========================================================================
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;       # Hereda el binario ya instalado por configuration.nix
    portalPackage = null; # Hereda el portal XDG de configuration.nix
    systemd.enable = true;
    extraConfig = builtins.readFile ./configs/hyprland.lua;
  };

  # Sincronizar variables de entorno de Hyprland con systemd
  wayland.windowManager.hyprland.systemd.variables = [ "--all" ];

  xdg.configFile."hypr/hyprpaper.conf".source = ./configs/hyprpaper.conf;

  # =========================================================================
  # 6. Variables de Entorno y Estado de Home Manager
  # =========================================================================
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Versión del estado de Home Manager (mantiene compatibilidad)
  home.stateVersion = "26.05";
}
