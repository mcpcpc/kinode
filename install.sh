#!/bin/sh
# script to configure and install KISS Linux on a Linode VPS
ver=2021.5-1
url=https://github.com/kiss-community/repo/releases/download/$ver
giturl=
hn=mcpcpc
sdX=sda

cd $HOME
mkfs.ext4 -F /dev/sda1
mkfs.ext4 -F /dev/sda3
mkfs.vfat -F 32 /dev/sda2
mount /dev/sda3 /mnt
wget "$url/kiss-chroot-$ver.tar.xz" 
tar xvf kiss-chroot-$ver.tar.xz -C /mnt --strip-components 1
mount /dev/sda1 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda2 /mnt/boot/efi
echo -e "/dev/sda1\t\t/boot\t\tvfat\t\tnoauto,noatime\t1 2" >> /mnt/etc/fstab
echo -e "/dev/sda3\t\t/\t\text4\t\tnoatime\t\t0 1" >> /mnt/etc/fstab
echo "$hn" >> /mnt/etc/hostname
/mnt/bin/kiss-chroot /mnt <<"EOT"
export CFLAGS="-O1 -pipe -march=native"
export CXXFLAGS="-O1 -pipe -march=native"
export MAKEFLAGS="-j2"
export KISS_PROMPT=0
kiss update
cd /var/db/kiss/installed && kiss build *
kiss b e2fsprogs && kiss i e2fsprogs
kiss b dosfstools && kiss i dosfstools
kiss b eudev && kiss i eudev
kiss b libelf && kiss i libelf
kiss b ncurses && kiss i ncurses
kiss b openssh && kiss i openssh
adduser mc
addgroup mc video
addgroup mv audio
#mkdir ~/repos
#cd ~/repos
#git clone https://github.com/kiss-community/repo  
echo $$
EOT
