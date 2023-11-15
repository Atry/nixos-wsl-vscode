{ inputs, lib, ... }: {
  flake.nixosModules.vscode = { config, pkgs, ... }: {
    imports = [ inputs.nixos-wsl.nixosModules.wsl ];

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
      { src = "${pkgs.gnutar}/bin/tar"; }
      { src = "${pkgs.gzip}/bin/gzip"; }
    ];
    programs.nix-ld = {
      enable = true;
      libraries = [
        # Required by NodeJS installed by VS Code's Remote WSL extension
        pkgs.stdenv.cc.cc
      ];

      # Use `nix-ld-rs` instead of `nix-ld`, because VS Code's Remote WSL extension launches a non-login non-interactive shell, which is not supported by `nix-ld`, while `nix-ld-rs` works in non-login non-interactive shells.
      package = inputs.nix-ld-rs.packages.${pkgs.system}.nix-ld-rs;
    };
  };

}
