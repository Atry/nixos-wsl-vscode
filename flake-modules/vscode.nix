{ inputs, lib, ... }: {
  flake.nixosModules.vscode = { config, pkgs, ... }: {
    imports = [
      inputs.nixos-wsl.nixosModules.wsl
      inputs.nix-ml-ops.nixosModules.nixLd
    ];

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
      { src = "${pkgs.gnutar}/bin/tar"; }
      { src = "${pkgs.gzip}/bin/gzip"; }
    ];
  };

}
