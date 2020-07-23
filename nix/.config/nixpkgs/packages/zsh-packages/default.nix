{ callPackage
, grml-zsh-config
, nix-zsh-completions
, oh-my-zsh
, zsh-autosuggestions
, zsh-completions
, zsh-syntax-highlighting
}:
let
  zshPackages = (builtins.fromJSON (builtins.readFile ./versions.json));
in
{
  inherit grml-zsh-config;

  inherit nix-zsh-completions;

  oh-my-zsh = oh-my-zsh.overrideAttrs (attrs: {
    postInstall = ''
      mkdir -p $out/share/zsh/plugins/colored-man-pages
      cp $out/share/oh-my-zsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh $out/share/zsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh

      mkdir -p $out/share/zsh/site-functions
      cp $out/share/oh-my-zsh/plugins/docker/_docker $out/share/zsh/site-functions
      cp $out/share/oh-my-zsh/plugins/docker-compose/_docker-compose $out/share/zsh/site-functions
      cp $out/share/oh-my-zsh/plugins/docker-compose/_docker-machine $out/share/zsh/site-functions
    '';
  });

  pure = callPackage
    ({ stdenv, fetchgit }: stdenv.mkDerivation {
      pname = "pure";

      version = zshPackages.pure.rev;

      src = fetchgit {
        inherit (zshPackages.pure) url rev sha256;
      };

      installPhase = ''
        mkdir -p $out/share/zsh/site-functions
        cp async.zsh $out/share/zsh/site-functions/async
        cp pure.zsh $out/share/zsh/site-functions/prompt_pure_setup
      '';

      meta = with stdenv.lib; {
        homepage = https://github.com/sindresorhus/pure;
        description = "Pretty, minimal and fast ZSH prompt";
        license = licenses.mit;
        platforms = platforms.unix;
        maintainers = with maintainers; [ eqyiel ];
      };
    }) { };

  zsh-autosuggestions = zsh-autosuggestions.overrideAttrs (attrs: {
    installPhase = ''
      install -D zsh-autosuggestions.zsh \
        $out/share/zsh/plugins/autosuggestions/zsh-autosuggestions.plugin.zsh
    '';
  });

  inherit zsh-completions;

  zsh-syntax-highlighting = zsh-syntax-highlighting.overrideAttrs (attrs: {
    installFlags = [
      "PREFIX=$(out)"
      "SHARE_DIR=$(out)/share/zsh/plugins/syntax-highlighting"
    ];

    postInstall = ''
      mv $out/share/zsh/plugins/syntax-highlighting/zsh-syntax-highlighting.zsh $out/share/zsh/plugins/syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
    '';
  });
}
