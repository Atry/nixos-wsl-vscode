topLevel@{ inputs, lib, ... }: {
  flake.nixosModules.vscodeServerWslTunnels = nixosModule@{ pkgs, ... }: {
    imports = [
      inputs.nixos-wsl.nixosModules.wsl
      topLevel.config.flake.nixosModules.vscodeServerWsl

    ];
    config = {

      wsl.extraBin = [
        # VS Code's "Remote - Tunnels" extension does not respect `~/.vscode-server/server-env-setup`, so we need to provide these binaries under `/bin`.
        { src = "${pkgs.coreutils}/bin/uname"; }
        { src = "${pkgs.coreutils}/bin/rm"; }
        { src = "${pkgs.coreutils}/bin/mkdir"; }
        { src = "${pkgs.coreutils}/bin/mv"; }

        { src = "${pkgs.coreutils}/bin/dirname"; }
        { src = "${pkgs.coreutils}/bin/readlink"; }
        { src = "${pkgs.coreutils}/bin/wc"; }
        { src = "${pkgs.coreutils}/bin/date"; }
        { src = "${pkgs.coreutils}/bin/sleep"; }
        { src = "${pkgs.coreutils}/bin/cat"; }
        { src = "${pkgs.gnused}/bin/sed"; }
        { src = "${pkgs.gnutar}/bin/tar"; }
        { src = "${pkgs.gzip}/bin/gzip"; }
      ];
    };
  };

}
