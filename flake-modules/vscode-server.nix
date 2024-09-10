{ inputs, lib, ... }: {
  flake.nixosModules.vscodeServer = nixosModule@{ pkgs, ... }: {
    imports = [
      inputs.nix-ml-ops.nixosModules.nixLd
      inputs.home-manager.nixosModules.home-manager
    ];
    options.vscodeServer = {
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "the list of users who would use VSCode server, by default all the normal users in the NixOS configuration";
        default = lib.trivial.pipe nixosModule.config.users.users [
          (lib.attrsets.filterAttrs (_: userConfig: userConfig.isNormalUser))
          lib.attrNames
        ];
      };
      serverEnvSetup = lib.mkOption {
        type = lib.types.lines;
        description = "the content of `~/.vscode-server/server-env-setup`";
      };
    };
    config = {
      vscodeServer.serverEnvSetup = ''
        export PATH=$PATH:${lib.makeBinPath [ pkgs.wget ]}
        export EDITOR="code --wait"
      '';
      home-manager = {
        sharedModules = [
          {
            home.stateVersion = lib.mkDefault "23.11";
          }
        ];
        users = lib.pipe nixosModule.config.vscodeServer.users [
          (builtins.map (name: {
            inherit name;
            value.home.file.".vscode-server/server-env-setup".text = nixosModule.config.vscodeServer.serverEnvSetup;
          }))
          builtins.listToAttrs
        ];
      };

      programs.nix-ld.libraries = [
        pkgs.zlib
      ];
    };
  };

}
