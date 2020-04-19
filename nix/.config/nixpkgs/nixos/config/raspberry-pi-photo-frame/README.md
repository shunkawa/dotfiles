```
nix build
```

## Extract the image

```
nix-shell -p bzip2
```

## Copy the image to the disk

```
sudo dd if=nixos-sd-image-20.03pre-git-aarch64-linux.img of=/dev/disk2 bs=4M status=progress
```

## Afterwards

1. Change `/Volumes/FIRMWARE/config.txt` to rotate display
2. Power up the device with ethernet
3. `ssh root@...` (find the address by DHCP lease) and add secrets for `wpa_supplicant` and `davfs2`
