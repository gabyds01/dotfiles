# Punto de partida para reconstruir la configuracion
# reemplazando la dependencia de los channels tradicionales

{
  description = "Configuracion modular con Flakes y Home Manager";

  inputs = {
    # Apuntamos a la rama inestable de Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Añadimos Home Manager como input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Le dice a HM que use los mismos paquetes
    };

    # Añadimos el Flake oficial de Antigravity
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

	    # Cargamos el modulo de Home Manager en el sistema
	    home-manager.nixosModules.default
	    {
	      home-manager = {
	        useGlobalPkgs = true;
	        useUserPackages = true;
	        # Definimos el archivo de configuracion para el usuario
            extraSpecialArgs = { inherit inputs; };
	        users.gabrields = import ./home.nix;
	      };
	    }
      ];
    };
  };
}
