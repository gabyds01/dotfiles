{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # 1. Configuración básica de Neovim escrita directamente en Lua
    extraLuaConfig = ''
      -- Opciones básicas del editor
      vim.opt.number = true            -- Muestra números de línea
      vim.opt.relativenumber = true    -- Números de línea relativos
      vim.opt.shiftwidth = 2           -- Indentación de 2 espacios
      vim.opt.tabstop = 2
      vim.opt.expandtab = true         -- Convierte tabuladores en espacios
      vim.opt.smartindent = true
      vim.opt.termguicolors = true     -- Colores reales en la terminal
      vim.g.mapleader = " "
    '';

    # 2. Gestiona Plugins directamente desde el canal de Nixpkgs
    plugins = with pkgs.vimPlugins; [
    ];

    # 3. "Batteries-Included": Dependencias del sistema requeridas por Neovim
    extraPackages = with pkgs; [
      # Herramientas de portapapeles indispensables
      wl-clipboard # Para entornos Wayland
      
      # Herramientas CLI necesarias para plugins específicos
      ripgrep      # Indispensable para que funcione Telescope
      
      # Servidores de Lenguaje (LSP) que se instalarán junto al editor
      nil          # LSP para lenguaje Nix
    ];
  };
}
