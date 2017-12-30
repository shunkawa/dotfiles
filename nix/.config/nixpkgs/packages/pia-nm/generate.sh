#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo 'usage: PIA_USERNAME="nobody" PASSWORD="hackme" ./generate.sh'
  exit 1
}

test -n "$PIA_USERNAME" || usage
test -n "$PASSWORD" || usage

cleanup() {
  sudo umount ./jail/proc/
  sudo umount ./jail/sys/
  sudo umount ./jail/dev/
  sudo umount ./jail/bin/
  sudo umount ./jail/usr/
  sudo umount ./jail/run/
  sudo umount ./jail/nix/
  rm -rfv ./jail/etc/{ssl,resolv.conf}
  mv jail/etc ./etc
  sudo chmod 777 -R ./etc
  rm -rfv ./jail
  cd ./etc/NetworkManager/system-connections
  for f in *; do
    # magic snippet to get rid of dns leaks with NM
    # https://bugzilla.gnome.org/show_bug.cgi?id=783569#c23
    echo -e "dns-priority=-42\ndns-search=\n" >> "$f"
    mv "$f" "${f// /_}";
  done
}

trap 'cleanup' EXIT

sudo rm -rf ./etc
mkdir -p jail/{proc,sys,dev,bin,usr,run,nix}
curl https://www.privateinternetaccess.com/installer/pia-nm.sh > jail/pia-nm.sh
sed -i '0,/\/bin\/bash/s/\/bin\/bash/\/usr\/bin\/env bash\nset -e\nfunction whoami() { echo 'root'; }/' jail/pia-nm.sh
sed -i 's/password-flags=1/password-flags=0/' jail/pia-nm.sh
chmod +x jail/pia-nm.sh
mkdir -p jail/etc/{openvpn,ssl/certs,NetworkManager/system-connections}
cp /etc/resolv.conf jail/etc/resolv.conf
cp -L /etc/ssl/certs/ca-bundle.crt jail/etc/ssl/certs/ca-bundle.crt
cp -L /etc/ssl/certs/ca-certificates.crt jail/etc/ssl/certs/ca-certificates.crt
sudo mount -t proc proc jail/proc
sudo mount -o bind /sys jail/sys/
sudo mount -o bind /dev jail/dev/
sudo mount -o bind,ro /bin jail/bin/
sudo mount -o bind,ro /usr jail/usr/
sudo mount -o bind,ro /run jail/run/
sudo mount -o bind,ro /nix jail/nix/

CONNECTION_METHOD="tcp"
STRONG_ENCRYPTION="y"

cat << EOF | sudo chroot jail
printf "${PIA_USERNAME}\n${CONNECTION_METHOD}\n${STRONG_ENCRYPTION}\n" \
  | ./pia-nm.sh
EOF
