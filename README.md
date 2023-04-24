# nixos-wsl-vscode
A nixos configuration that works with VS Code

## Usage:

Switch to the `main` branch of this configuration:

```
sudo nixos-rebuild --impure --flake github:Atry/nixos-wsl-vscode#nixosWslVsCode switch
```

Switch to a local work directory this configuration:

```
sudo nixos-rebuild --impure --flake .#nixosWslVsCode switch
```