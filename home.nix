{ config, pkgs, ... }:

{
  # Usuario y directorio de inicio
  home.username = "gabrields";
  home.homeDirectory = "/home/gabrields";

  # Paquetes declarativos del usuario (ejemplo: git, bat)
  home.packages = with pkgs; [
    bat
    git
    # Aquí iremos añadiendo herramientas más adelante
  ];

  # Configuraciones declarativas directas (ejemplo: Git)
  programs.git = {
    enable = true;
    userName = "gabyds01";
    userEmail = "gabyingds01@gmail.com";
  };

  # Esta version de estado es requerida para evitar problemas de compatibilidad
  home.stateVersion = "24.11"; 
}
