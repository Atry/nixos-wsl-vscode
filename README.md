# nixos-wsl-vscode
A nixos configuration that works with VS Code

## Usage:

### As a NixOS module in your flake

```nix
{
  inputs.nixos-wsl-vscode.url = "github:Atry/nixos-wsl-vscode";

  outputs = { self, nixpkgs, vscode-server }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      modules = [
        nixos-wsl-vscode.nixosModules.vscode
        ({ config, pkgs, ... }: {
          # rest of your configuration
        })
      ];
    };
  };
}
```
### As a NixOS module in your `configuration.nix`

```
{ config, pkgs, ... }:{
  imports = [
    (builtins.getFlake "github:Atry/nixos-wsl-vscode").nixosModules.vscode
  ];

  # rest of your configuration
}
```


### As a NixOS configuration

Switch to the `main` branch of this configuration:

```
sudo nixos-rebuild --impure --flake github:Atry/nixos-wsl-vscode#nixosWslVsCode switch
```

Switch to a local work directory this configuration:

```
sudo nixos-rebuild --impure --flake .#nixosWslVsCode switch
```

Note that this NixOS configuration also includes [other optionated settings](https://github.com/Atry/nixos-wsl-vscode/blob/5d1b74b6b39cd9eb26d62e2ffa90ceaa38278352/flake.nix#L35-L82).
