# ~/.config/dotfiles

## Bootstrapping a new comptuer

First, take an snapshot in the pristine state. For APFS:

```
$ tmutil localsnapshot
```

### Install `nix`

See the [section of the manual about installing](https://nixos.org/nix/manual/#ch-installing-binary).

```
$ ALLOW_PREEXISTING_INSTALLATION=1 sh <(curl -L https://nixos.org/nix/install) --daemon --darwin-use-unencrypted-nix-store-volume
```

[`ALLOW_PREEXISTING_INSTALLATION`](https://github.com/NixOS/nix/blob/090960b7254799a14bd5dc3b61f1a4d7c6a95733/scripts/install-multi-user.sh#L316-L318) is not documented in the manual but does what it says on the box.

Install something into `$NIX_PROFILE`, [just to create that directory](https://github.com/NixOS/nix/issues/3051):

```
$ nix-env -i hello
```

### Clone this repository

Use a transient `nix-shell` environment:

```
$ nix-shell -p cachix git gnupg pass stow transcrypt
```

Connect the security key and ask GPG to read the key info to be sure the card is connected:

```
$ gpg2 --card-status
```

Fetch the private key on the smartcard (it will download the public key if you don't have it already):

```
$ gpg2 --card-edit
gpg/card> fetch
```

And configure the key for encryption:

```
gpg --edit-key 318320201A66BD7F78C2E729FDAD61AB3311FA17
```

Enter `trust` at the prompt and select `5 trust ultimately`, `save` the changes and exit.

Configure SSH to use the GPG key for authentication:

```
$ killall ssh-agent gpg-agent
$ unset GPG_AGENT_INFO SSH_AGENT_PID SSH_AUTH_SOCK
$ eval $(gpg-agent --daemon --enable-ssh-support)
```

To know whether it was successful, check that the public key is present in the output of `ssh-add -L` (it should have a comment like `cardno:`).

Now find the authentication key's keygrip. It should be marked with `[A]` in the output of:

```
$ gpg2 --with-keygrip -k
```

Whitelist that keygrip in `~/.gnupg/sshcontrol`:

```
$ echo '<keygrip>' >> ~/.gnupg/sshcontrol
```

[Test that GitHub can be reached using SSH](https://docs.github.com/en/github/authenticating-to-github/testing-your-ssh-connection):

```
$ ssh -T git@github.com
```

At this point you should be prompted to unlock the card. Now:

```
$ mkdir -p ~/git/personal; cd !$

$ git clone --recursive ssh://git@github.com/eqyiel/dotfiles.git

$ git clone ssh://git@github.com/eqyiel/password-store.git

$ ln -s ~/git/personal/password-store/ ~/.password-store

$ ln -s ~/git/personal/dotfiles ~/.config/dotfiles
```

### Create symlinks using GNU `stow`

```
$ cd dotfiles
$ ./decrypt.sh
$ stow --target "${HOME}" --restow bin emacs git gnupg macos mail nix ssh zsh # for example
```

### Bootstrap `nix-darwin`

```
$ cd ~/.nix-defexpr/darwin
$ export NIX_PATH=darwin=$HOME/.nix-defexpr/darwin:darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix:$NIX_PATH
$ "$(nix-build -A installer --no-out-link)/bin/installer"
$ PATH="~/.local/bin:$PATH" rebuild-darwin
```

### Bootstrap `cachix`

```
~
❯ "$(nix-build -A cachix https://cachix.org/api/v1/install --no-out-link)/bin/cachix" authtoken $(pass cachix/eqyiel/authtoken)
Written to /Users/eqyiel/.config/cachix/cachix.dhall
```
