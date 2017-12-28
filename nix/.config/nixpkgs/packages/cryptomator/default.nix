{ stdenv
 , fetchgit
 , gtk2
 , javafx
 , jdk
 , jre
 , makeDesktopItem
 , makeWrapper
 , maven
 , webkitgtk2
 , writeText
 , xorg
 }:

let

  commonDescription = "Multi-platform transparent client-side encryption of "
    + "your files in the cloud.";

  ldLibraryPath = (stdenv.lib.makeLibraryPath [
    gtk2
    webkitgtk2
    xorg.libXtst
  ]) + ":${javafx}/rt/lib/amd64";

  withJFXPatch = writeText "with-javafx.patch" ''
    From 1fc491821a44c1e6e4a8f4ffaf55a44a8990c30e Mon Sep 17 00:00:00 2001
    From: Ruben Maher <r@rkm.id.au>
    Date: Fri, 27 Jan 2017 05:54:19 +1030
    Subject: [PATCH]

    ---
     main/ui/pom.xml | 7 +++++++
     1 file changed, 7 insertions(+)

    diff --git a/main/ui/pom.xml b/main/ui/pom.xml
    index 06a4790..f6fa3d4 100644
    --- a/main/ui/pom.xml
    +++ b/main/ui/pom.xml
    @@ -124,5 +124,12 @@
          <artifactId>zxcvbn</artifactId>
          <version>1.1.1</version>
        </dependency>
    +
    +		<!-- JavaFX -->
    +		<dependency>
    +			<groupId>javafx</groupId>
    +			<artifactId>jfxrt.jar</artifactId>
    +			<version>${javafx.repover}</version>
    +		</dependency>
      </dependencies>
     </project>
    --
    2.10.0
  '';

  desktopItem = makeDesktopItem {
    name = "Cryptomator";
    exec = "cryptomator";
    icon = "cryptomator";
    comment = commonDescription;
    desktopName = "Cryptomator";
    genericName = "Cryptomator";
    categories = "Application;";
  };

in
 stdenv.mkDerivation rec {
  name = "cryptomator-${version}";
  version = "1.2.4";

  src = fetchgit {
    url = "git@github.com:cryptomator/cryptomator.git";
    rev = "0c0fb1c4c58a1d66ff43a8d9a5f9d01cdc1dc816";
    sha256 = "1ighd3215aik7xbalc1x7qlc8gfc6g4adz90vi3zp1rard6iap66";
  };

  buildInputs = [
    gtk2
    jdk
    jre
    makeWrapper
    maven
    webkitgtk2
    xorg.libXtst
  ];

  buildPhase = ''
    mkdir "lib"
    mvn install:install-file \
      -Dmaven.repo.local="lib" \
      -DgroupId=javafx \
      -DartifactId=jfxrt.jar \
      -Dpackaging=jar \
      -Dversion=${javafx.repover} \
      -Dfile=${javafx}/rt/lib/ext/jfxrt.jar \
      -DgeneratePom=true
    patch --strip 1 --ignore-whitespace --unified < ${withJFXPatch}
    cd main
    mvn -Dmaven.repo.local="../lib" clean install -Prelease
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/share/java"
    mv "uber-jar/target/Cryptomator-${version}.jar" "$out/share/java"
    makeWrapper "${jre}/bin/java" "$out/bin/cryptomator" \
      --add-flags "-jar $out/share/java/Cryptomator-${version}.jar" \
      --prefix LD_LIBRARY_PATH : ${ldLibraryPath}

    # Create desktop item.
    mkdir -p $out/share/applications
    cp "${desktopItem}/share/applications/"* "$out/share/applications"
    mkdir -p "$out/share/pixmaps"
    cp "ui/src/main/resources/img/dialog-appicon@2x.png" \
       "$out/share/pixmaps/cryptomator.png"
  '';

  meta = with stdenv.lib; {
    description = commonDescription;
    homepage = https://cryptomator.org;
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
