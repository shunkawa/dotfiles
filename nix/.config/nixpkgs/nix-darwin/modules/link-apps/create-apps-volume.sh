#!/bin/sh

# This is a rip-off of https://github.com/LnL7/nix/blob/2a7ea2eb6c54c82d5e858ea6ae9de929face5e55/scripts/create-darwin-volume.sh

set -e

root_disk() {
  diskutil info -plist /
}

apfs_volumes_for() {
  disk=$1
  diskutil apfs list -plist "$disk"
}

disk_identifier() {
  xpath "/plist/dict/key[text()='ParentWholeDisk']/following-sibling::string[1]/text()" 2>/dev/null
}

volume_list_true() {
  key=$1
  xpath "/plist/dict/array/dict/key[text()='Volumes']/following-sibling::array/dict/key[text()='$key']/following-sibling::true[1]" 2> /dev/null
}

volume_get_string() {
  key=$1 i=$2
  xpath "/plist/dict/array/dict/key[text()='Volumes']/following-sibling::array/dict[$i]/key[text()='$key']/following-sibling::string[1]/text()" 2> /dev/null
}

find_spotlight_volume() {
  disk=$1
  i=1
  volumes=$(apfs_volumes_for "$disk")
  while true; do
    name=$(echo "$volumes" | volume_get_string "Name" "$i")
    if [ -z "$name" ]; then
      break
    fi
    case "$name" in
      "Nix Apps"*)
        echo "$name"
        break
        ;;
    esac
    i=$((i+1))
  done
}

test_fstab() {
  grep -q "/spotlight apfs rw" /etc/fstab 2>/dev/null
}

test_spotlight_symlink() {
  [ -L "/spotlight" ] || grep -q "^spotlight." /etc/synthetic.conf 2>/dev/null
}

test_synthetic_conf() {
  grep -q "^spotlight$" /etc/synthetic.conf 2>/dev/null
}

test_spotlight() {
  test -d "/spotlight"
}

main() {
  if ! test_synthetic_conf; then
    echo "Configuring /etc/synthetic.conf..." >&2
    echo spotlight | sudo tee -a /etc/synthetic.conf
    if ! test_synthetic_conf; then
      echo "error: failed to configure synthetic.conf;" >&2
      exit 1
    fi
  fi

  if ! test_spotlight; then
    echo "Creating mountpoint for /spotlight..." >&2
    /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -B || true
    if ! test_spotlight; then
      sudo mkdir -p /spotlight 2>/dev/null || true
    fi
    if ! test_spotlight; then
      echo "error: failed to bootstrap /spotlight" >&2
      exit 1
    fi
  fi

  disk=$(root_disk | disk_identifier)
  volume=$(find_spotlight_volume "$disk")
  if [ -z "$volume" ]; then
    echo "Creating a volume..." >&2
    sudo diskutil apfs addVolume "$disk" APFS 'Nix Apps' -mountpoint /spotlight
    volume="Nix Apps"
  else
    echo "Using existing '$volume' volume" >&2
  fi

  if ! test_fstab; then
    echo "Configuring /etc/fstab..." >&2
    label=$(echo "$volume" | sed 's/ /\\040/g')
    printf "\$a\nLABEL=%s /spotlight apfs rw\n.\nwq\n" "$label" | EDITOR=ed sudo vifs
  fi
}

main "$@"
