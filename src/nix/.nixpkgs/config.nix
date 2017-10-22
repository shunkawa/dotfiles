{
  overlays = let
    nixpkgsMozilla = (import <nixpkgs> { config = { }; }).fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    rev = "HEAD";
    sha256 = "1lim10a674621zayz90nhwiynlakxry8fyz1x209g9bdm38zy3av";
    fetchSubmodules = true;
  };
in [(import "${nixpkgsMozilla}/rust-overlay.nix")];
  allowBroken = true;
  allowUnfree = true;
  permittedInsecurePackages = [
    "webkitgtk-2.4.11"
  ];

  packageOverrides = pkgs: with pkgs; {
    # purs = with pkgs.rustChannels.nightly; buildRustPackage rec {
    #   name = "purs-${version}";
    #   version = "HEAD";

    #   src = pkgs.fetchFromGitHub {
    #     owner = "xcambar";
    #     repo = "purs";
    #     rev = "${version}";
    #     sha256 = "0h0bv2nd3vp9ak16bfq52sc9b28m8ch7q8dj6zmjlrnjslhyaqjv";
    #   };

    #   buildInputs = [ pkgs.openssl ];

    #   depsSha256 = "1skbl757g47ygkzq54l6v1kibyg2j2si947h7yggryycncd8vm3y";
    # };
  };
}
