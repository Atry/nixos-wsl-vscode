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
      url = "github:Atry/NixOS-WSL/patch-2";
      # TODO: switch to official NixOS-WSL once https://github.com/nix-community/NixOS-WSL/pull/339 gets merged
      # url = "github:nix-community/NixOS-WSL";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
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
          inputs.nixos-wsl.nixosModules.wsl
          flake.config.nixosModules.vscode
          ({ lib, pkgs, config, ... }: {
            wsl = {
              enable = true;
              wslConf.automount.root = "/mnt";
              defaultUser = "nixos";
              startMenuLaunchers = true;
              useWslLib = true;
            };

            hardware.opengl.setLdLibraryPath = true;

            # Enable nix flakes
            nix.extraOptions = ''
              experimental-features = nix-command flakes
            '';
            nix.settings.trusted-users = [ config.wsl.defaultUser ];
            nix.settings.extra-substituters = [
              "https://nix-community.cachix.org"
            ];
            nix.settings.extra-trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
            nix.settings.auto-optimise-store = true;

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
