{ stdenv
, pinentry
, pinentry_mac
, writeScriptBin
}: writeScriptBin pinentry.pname ''
  #!${stdenv.shell}

  ${if stdenv.isDarwin then ''
       ${pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '' else ''
     ${pinentry}/bin/pinentry
  ''}
''
