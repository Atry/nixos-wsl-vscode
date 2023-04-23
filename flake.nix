{
  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

  outputs = { nixos-wsl, nixpkgs, ... }: {
    nixosConfigurations.nixosWslVsCode = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, lib, ... }: {
          imports = [ nixos-wsl.nixosModules.wsl ];

          wsl = {
            enable = true;
            wslConf.automount.root = "/mnt";
            defaultUser = "nixos";
            startMenuLaunchers = true;

            # Enable native Docker support
            # docker-native.enable = true;

            # Enable integration with Docker Desktop (needs to be installed)
            # docker-desktop.enable = true;

          };

          # Enable nix flakes
          nix.package = pkgs.nixFlakes;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
            extra-sandbox-paths = /usr/lib/wsl
          '';
          nix.settings.extra-substituters = [
            "https://nix-community.cachix.org"
          ];
          nix.settings.extra-trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          system.stateVersion = "22.05";

          environment.systemPackages = with pkgs; [
            wget
            cachix
            python310Packages.poetry
            direnv
            nix-direnv
          ];

          programs.nix-ld.enable = true;

          programs.git.enable = true;

          # Required settings for direnv
          nix.settings.keep-outputs = true;
          nix.settings.keep-derivations = true;
          environment.pathsToLink = [
            "/share/nix-direnv"
          ];
          nixpkgs.overlays = [
            (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; })
          ];
          programs.bash.interactiveShellInit = lib.mkAfter ''
            eval "$(direnv hook bash)"
          '';

          # Enable them after upgrading to nixos 23.05
          # programs.nix-ld.libraries = with pkgs; [
          #   stdenv.cc.cc
          #   zlib
          #   fuse3
          #   icu
          #   nss
          #   openssl
          #   curl
          #   expat
          #   # ...
          # ];
        })
      ];
    };
  };

}