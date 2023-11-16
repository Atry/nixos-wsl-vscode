{ inputs, lib, ... }: {
  flake.nixosModules.vscode = { config, pkgs, ... }: {
    imports = [
      inputs.nixos-wsl.nixosModules.wsl
      inputs.nix-ml-ops.nixosModules.nixLd
      inputs.home-manager.nixosModules.home-manager
    ];
    home-manager.users =
      lib.trivial.pipe config.users.users [
        (lib.attrsets.filterAttrs (_: userConfig: userConfig.isNormalUser))
        (lib.attrsets.mapAttrs (userName: userConfig: {
          home.stateVersion = "23.11";
          home.file.".vscode-server/server-env-setup".text = ''
            export PATH=$PATH:${
              lib.strings.makeBinPath [
                pkgs.coreutils
                pkgs.gnutar
                pkgs.gzip
                pkgs.wget
                pkgs.gnused
                pkgs.gawk
              ]
            }
          '';
        }))
      ];
  };

}
