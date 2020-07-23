# ~/.config/dotfiles

## Bootstrapping

### Install `nix`

See the [section of the manual about installing](https://nixos.org/nix/manual/#ch-installing-binary).

```
ALLOW_PREEXISTING_INSTALLATION=1 sh <(curl -L https://nixos.org/nix/install) --daemon --darwin-use-unencrypted-nix-store-volume
```

[`ALLOW_PREEXISTING_INSTALLATION`](https://github.com/NixOS/nix/blob/090960b7254799a14bd5dc3b61f1a4d7c6a95733/scripts/install-multi-user.sh#L316-L318) is not documented in the manual but does what it says on the box.

### Create symlinks to dotfiles using GNU `stow`

```sh
nix-shell -p stow --command 'stow -t "${HOME}" emacs -R'
```
