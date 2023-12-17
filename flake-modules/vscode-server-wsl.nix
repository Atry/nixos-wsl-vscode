topLevel@{ inputs, lib, ... }: {
  imports = [
    ./vscode-server.nix
  ];
  flake.nixosModules.vscodeServerWsl = nixosModule: {
    imports = [
      inputs.nixos-wsl.nixosModules.wsl
      topLevel.config.flake.nixosModules.vscodeServer
    ];
    config.vscodeServer.serverEnvSetup = ''
      # Workaround for https://github.com/nix-community/NixOS-WSL/issues/171
      . ${lib.escapeShellArg nixosModule.config.system.build.setEnvironment}
    '';
  };

}
