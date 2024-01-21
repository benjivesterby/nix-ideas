{
  inputs,
  overlays,
  stateVersion,
}: let
  home-manager = inputs.home-manager;

  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    overlays = overlays;
  };

  nur = import inputs.nur {
    inherit pkgs;
    nurpkgs = pkgs;
  };

  lib =
    pkgs.lib.extend
    (self: super:
      {
        my = import ./lib.nix {
          inherit pkgs;
          lib = self;
        };
      }
      // home-manager.lib);

  commonModules = [
    ../cachix.nix
    ../roles
    ../colors
  ];

  hmModules = [
    ../home
    ../services
  ];

  mkHomeConfiguration = configurationName: machine:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules =
        commonModules
        ++ hmModules
        ++ [
          inputs.stylix.homeManagerModules.stylix
          machine
        ];
      extraSpecialArgs = {
        inherit inputs configurationName stateVersion lib nur;
        isStandalone = true;
      };
    };

  mkNixosConfiguration = configurationName: machine:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      system = "x86_64-linux";
      modules =
        commonModules
        ++ [
          home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          ../system
          machine
          ({config, ...}: {
            system.stateVersion = stateVersion;
            nix.settings.experimental-features = [
              "flakes"
              "nix-command"
            ];

            home-manager = {
              useUserPackages = false;
              useGlobalPkgs = true;
              extraSpecialArgs = {
                inherit inputs configurationName stateVersion lib nur;
                roles = config.my.roles;
                colors = config.my.colors;
                isStandalone = false;
              };
              users.calops.imports = hmModules;
            };
          })
        ];
      specialArgs = {
        inherit inputs configurationName stateVersion lib;
        isStandalone = false;
      };
    };
in {
  mkNixosConfigurations = configs:
    lib.attrsets.mapAttrs' (host: machine: let
      configurationName = host;
    in (lib.attrsets.nameValuePair
      configurationName (mkNixosConfiguration configurationName machine)))
    configs;

  mkHomeConfigurations = configs:
    lib.attrsets.mapAttrs' (host: machine: let
      configurationName = "${machine.home.username}@${host}";
    in (lib.attrsets.nameValuePair
      configurationName (mkHomeConfiguration configurationName machine)))
    configs;

  # TODO: split each shell into its own derivation
  mkDevShells = shells: shells {inherit pkgs inputs;};
}
