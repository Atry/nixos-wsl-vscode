{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-ml-ops = {
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Preemo-Inc/nix-ml-ops";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/NixOS-WSL";
    };
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
    imports =
      lib.trivial.pipe ./flake-modules [
        builtins.readDir
        (lib.attrsets.filterAttrs (name: type: type == "regular" && lib.strings.hasSuffix ".nix" name))
        builtins.attrNames
        (builtins.map (name: ./flake-modules/${name}))
      ] ++
      [
        inputs.nix-ml-ops.flakeModules.nixIde
      ];

    flake = flake: {
      nixosConfigurations.nixosWslVsCode = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ lib, pkgs, ... }: {
            imports = [
              inputs.nixos-wsl.nixosModules.wsl
              flake.config.nixosModules.vscode
            ];

            wsl = {
              enable = true;
              wslConf.automount.root = "/mnt";
              defaultUser = "nixos";
              startMenuLaunchers = true;
            };

            hardware.opengl.package = pkgs.symlinkJoin {
              name = "wsl";
              paths = [ /usr/lib/wsl ];
            };

            # Enable nix flakes
            nix.package = pkgs.nixFlakes;
            nix.extraOptions = ''
              experimental-features = nix-command flakes
              extra-sandbox-paths = /usr/lib/wsl
            '';
            nix.settings.trusted-users = [ "nixos" ];
            nix.settings.extra-substituters = [
              "https://nix-community.cachix.org"
            ];
            nix.settings.extra-trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];

            nix.optimise.automatic = true;

            system.stateVersion = "22.05";

            environment.systemPackages = with pkgs; [
              wget
              cachix
            ];

            nixpkgs.config.allowUnfree = true;

            programs.git.enable = true;

            programs.direnv.enable = true;

          })
        ];
      };
    };
  });

}
