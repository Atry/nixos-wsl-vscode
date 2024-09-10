{ inputs, lib, ... }: {
  flake.nixosModules.vscodeServer = nixosModule@{ pkgs, ... }: {
    imports = [
      inputs.nix-ml-ops.nixosModules.nixLd
      inputs.home-manager.nixosModules.home-manager
    ];
    options.vscodeServer.serverEnvSetup = lib.mkOption {
      type = lib.types.lines;
      description = "the content of `~/.vscode-server/server-env-setup` for each normal user in the NixOS configuration, which would not affect users created from manual `useradd` command.";
    };
    config = {
      vscodeServer.serverEnvSetup = ''
        export PATH=$PATH:${lib.strings.makeBinPath [ pkgs.wget ]}
        export EDITOR="code --wait"
      '';
      home-manager.users =
        lib.trivial.pipe nixosModule.config.users.users [
          (lib.attrsets.filterAttrs (_: userConfig: userConfig.isNormalUser))
          (lib.attrsets.mapAttrs (userName: userConfig: {
            home.stateVersion = "23.11";
            home.file.".vscode-server/server-env-setup".text = nixosModule.config.vscodeServer.serverEnvSetup;
          }))
        ];
      programs.nix-ld.libraries = [
        pkgs.zlib
      ];
    };
  };

}
