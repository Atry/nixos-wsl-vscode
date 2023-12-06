topLevel@{ inputs, lib, ... }: {
  flake.nixosModules.vscodeServerWsl = nixosModule: {
    imports = [
      inputs.nixos-wsl.nixosModules.wsl
      topLevel.config.flake.nixosModules.vscodeServer
    ];
    config.vscodeServer.serverEnvSetup = ''
      # Workaround for https://github.com/nix-community/NixOS-WSL/issues/171
      . ${lib.escapeShellArg nixosModule.config.system.build.setEnvironment}
    '';
    wsl.extraBin = [
      # Required by VS Code's Remote WSL extension
      { src = "${pkgs.coreutils}/bin/dirname"; }
      { src = "${pkgs.coreutils}/bin/readlink"; }
      { src = "${pkgs.coreutils}/bin/uname"; }
      { src = "${pkgs.coreutils}/bin/rm"; }
      { src = "${pkgs.coreutils}/bin/wc"; }
      { src = "${pkgs.coreutils}/bin/date"; }
      { src = "${pkgs.coreutils}/bin/mv"; }
      { src = "${pkgs.coreutils}/bin/sleep"; }
      { src = "${pkgs.coreutils}/bin/mkdir"; }
      { src = "${pkgs.coreutils}/bin/tee"; }
      { src = "${pkgs.coreutils}/bin/chmod"; }
      { src = "${pkgs.gnutar}/bin/tar"; }
      { src = "${pkgs.gzip}/bin/gzip"; }
    ];
  };

}
