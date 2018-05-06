{ stdenv
, chromium ? null
, curlFull
, fetchFromGitHub
, makeWrapper
, python36Packages
, wget
}:

python36Packages.buildPythonApplication {
  format = "other";
  pname = "bookmark-archiver";
  version = "HEAD";

  src = fetchFromGitHub {
    owner = "pirate";
    repo = "bookmark-archiver";
    rev = "05adc74c69eb2e37a3d7b4c813afb6e360b3c8f1";
    sha256 = "005ibkmxf1yjhx9cgv2daw5n1y3j02d3s1jj7yp9kw9qs940ql7r";
  };

  buildInputs = [ wget curlFull ] ++ stdenv.lib.optional stdenv.isLinux chromium;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -a $src $out/libexec
    ls -lhaR $out/
    makeWrapper $out/libexec/archive.py $out/bin/bookmark-archiver \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';
}
