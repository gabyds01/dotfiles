{ config, pkgs, inputs, ... }:

{

  imports = [
    ./modules/neovim.nix
  ];

  # Usuario y directorio de inicio
  home.username = "gabrields";
  home.homeDirectory = "/home/gabrields";

  # Paquetes declarativos del usuario (ejemplo: git, bat)
  home.packages = with pkgs; [
    # Terminal y Herramientas de Consola
    alacritty
    tmux
    fzf
    ripgrep
    pyright
    marksman

    # Editores de Texo e IDEs
    zed-editor

    # Comuniacion
    discord
    telegram-desktop
    signal-desktop

    # Desarrollo y Productividad
    obsidian
    rnote
    qalculate-qt
    texliveFull

    # Utilidades
    qbittorrent

    # Instalamos el IDE oficial y su CLI desde el Flake externo
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-ide # El IDE
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-cli # La CLI (comando 'agy')
  ];

  # Configuraciones declarativas directas (ejemplo: Git)
  programs.git = {
    enable = true;
    settings = {
      user = {
        userName = "gabyds01";
        userEmail = "gabyingds01@gmail.com";
      };
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      # terminal.shell = {
      #   program = "${pkgs.tmux}/bin/tmux";
      # };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
      };
      bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
      };
      size = 12.0;
      };
    };
  };

  # Programas gestionados por Home Manager
  programs.firefox.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # 1. Le decimos a Home Manager que gestione Bash
  programs.bash = {
    enable = true;
    
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/dotfiles";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;       # Hereda el binario de configuration.nix
    portalPackage = null; # Hereda el portal XDG de configuration.nix
    extraConfig = builtins.readFile ./configs/hyprland.lua;
  };

  wayland.windowManager.hyprland.systemd.variables = ["--all"];

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Esta version de estado es requerida para evitar problemas de compatibilidad
  home.stateVersion = "26.05"; 
}
