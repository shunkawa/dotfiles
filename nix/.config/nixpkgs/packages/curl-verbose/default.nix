{ stdenv
, curl
, writeScriptBin
, writeText
}:

let
  write-out = writeText "write-out" ''
      \n*** cURL says:\n
      content_type       = %{content_type}\n
      filename_effective = %{filename_effective}\n
      ftp_entry_path     = %{ftp_entry_path}\n
      http_code          = %{http_code}\n
      http_connect       = %{http_connect}\n
      local_ip           = %{local_ip}\n
      local_port         = %{local_port}\n
      num_connects       = %{num_connects}\n
      num_redirects      = %{num_redirects}\n
      redirect_url       = %{redirect_url}\n
      remote_ip          = %{remote_ip}\n
      remote_port        = %{remote_port}\n
      size_download      = %{size_download} bytes\n
      size_header        = %{size_header} bytes\n
      size_request       = %{size_request} bytes\n
      size_upload        = %{size_upload} bytes\n
      speed_download     = %{speed_download} bytes per second\n
      speed_upload       = %{speed_upload} bytes per second\n
      ssl_verify_result  = %{ssl_verify_result}\n
      time_appconnect    = %{time_appconnect} seconds\n
      time_connect       = %{time_connect} seconds\n
      time_namelookup    = %{time_namelookup} seconds\n
      time_pretransfer   = %{time_pretransfer} seconds\n
      time_redirect      = %{time_redirect} seconds\n
      time_starttransfer = %{time_starttransfer} seconds\n
      time_total         = %{time_total} seconds\n
      url_effective      = %{url_effective}\n
    '';
in writeScriptBin "curl-verbose" ''
  #!${stdenv.shell}

  set -euo pipefail

  ${curl}/bin/curl --write-out @${write-out} "''${@}"
''
