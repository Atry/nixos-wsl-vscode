{
  inputs = {
    nixos-wsl.url = "github:Atry/NixOS-WSL/vscode";
  };
  outputs = { nixos-wsl, nixpkgs, ... }: {
    nixosConfigurations.nixosWslVsCode = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, lib, config, ... }: {
          imports = [ nixos-wsl.nixosModules.wsl ];

          wsl = {
            enable = true;
            wslConf.automount.root = "/mnt";
            defaultUser = "nixos";
            startMenuLaunchers = true;
            vscodeRemoteWslExtensionWorkaround.enable = true;

            # Enable native Docker support
            # docker-native.enable = true;

            # Enable integration with Docker Desktop (needs to be installed)
            # docker-desktop.enable = true;

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

}