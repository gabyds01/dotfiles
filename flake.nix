# =============================================================================
# Punto de entrada principal (Flake) para la configuración del sistema NixOS
# Permite reproducibilidad estricta bloqueando versiones exactas con flake.lock
# =============================================================================

{
  description = "Configuración modular de NixOS con Flakes y Home Manager";

  inputs = {
    # Repositorio principal de paquetes (rama inestable de NixOS)
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Gestión declarativa del entorno de usuario
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Sincroniza con la misma versión de nixpkgs
    };

    # Flake oficial de Google Antigravity (IDE y CLI)
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix

        # Módulo de integración de Home Manager en el sistema NixOS
        home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; }; # Permite acceder a inputs externos en home.nix
            users.gabrields = import ./home.nix;
          };
        }
      ];
    };
  };
}
