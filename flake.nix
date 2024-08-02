{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-ml-ops = {
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Atry/nix-ml-ops";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/NixOS-WSL";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
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
          inputs.nix-index-database.nixosModules.nix-index
          flake.config.nixosModules.vscodeServerWslTunnels
          ({ lib, pkgs, config, ... }: {
            wsl = {
              enable = true;
              wslConf.automount.root = "/mnt";
              defaultUser = "nixos";
              startMenuLaunchers = true;
              useWindowsDriver = true;
            };
            virtualisation = {
              docker = {
                enable = true;
                enableOnBoot = true;
                autoPrune.enable = true;
              };
              podman = {
                enable = true;
              };
            };
            users.extraGroups.docker.members = config.users.groups.wheel.members;

            hardware.nvidia-container-toolkit.enable = true;

            nix.package = pkgs.nixUnstable;

            # Enable nix flakes
            nix.extraOptions = ''
              experimental-features = nix-command flakes impure-derivations ca-derivations
            '';
            nix.settings.trusted-users = [ "@wheel" ];

            nix.settings.extra-substituters = [
              "https://nix-community.cachix.org"
              "https://cuda-maintainers.cachix.org"
            ];
            nix.settings.extra-trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            ];
            nix.settings.auto-optimise-store = true;
            nix.settings.extra-sandbox-paths = lib.mkIf config.wsl.useWindowsDriver [
              "/usr/lib/wsl"
            ];

            system.stateVersion = "22.05";

            environment.defaultPackages = [
              pkgs.cachix
              pkgs.wsl-open
            ];

            nixpkgs.config.allowUnfree = true;

            programs.git.enable = true;

            programs.direnv.enable = true;

            programs.command-not-found.enable = false;
            programs.nix-index.enable = true;
            programs.nix-index-database.comma.enable = true;
          })
        ];
      };
    };
  });

}
