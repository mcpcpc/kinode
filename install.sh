#!/bin/sh -e
#
# Kinode
# Description: KISS Linux OS installation script for a Linode VPS
# Author: Michael Czigler

# set global variables
ver=2021.5-1
url=https://github.com/kiss-community/repo/releases/download/$ver
user=mcpcpc
sdX=sda

# format and partition drive, sdX
cd $HOME
mkfs.ext4 -F /dev/sda1
mkfs.ext4 -F /dev/sda3
mkfs.vfat -F 32 /dev/sda2

# prepare drive for chroot/boostrap process
mount /dev/sda3 /mnt
wget "$url/kiss-chroot-$ver.tar.xz" 
tar xvf kiss-chroot-$ver.tar.xz -C /mnt --strip-components 1
mount /dev/sda1 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda2 /mnt/boot/efi
echo -e "/dev/sda1\t\t/boot\t\tvfat\t\tnoauto,noatime\t1 2" >> /mnt/etc/fstab
echo -e "/dev/sda3\t\t/\t\text4\t\tnoatime\t\t0 1" >> /mnt/etc/fstab
echo "$user" >> /mnt/etc/hostname

# chroot/bootstrap KISS Linux, setup new user 
# note: variables will not work here. All paths should be absolute.
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
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.47.tar.xz -P /usr/src
tar xvf /usr/src/linux-*
cd /usr/src/linux-*
wget https://raw.githubusercontent.com/mcpcpc/kinode/master/.config
make -j1
make modules_install
make install
echo $$
EOT

## post installation steps (e.g. after reboot
# adduser mc
# addgroup mc video
# addgroup mv audio
# su mc
# mkdir $HOME/repos
# cd $HOME/repos
# git clone https://github.com/kiss-community/repo  
