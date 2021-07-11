#!/bin/sh -e
#
# Kinode
# Description: KISS Linux OS installation script for a Linode VPS
# Author:      Michael Czigler
# 
# The following script is intended for bootstrapping a minimal KISS
# Linux server on linode.  In order to avoid OOM messages, I recommend
# at least 2GB of RAM for the initial VPS setup. The VPS plan can
# always be changed later. 

ver=2021.7-4
kver=5.10.47
url=https://github.com/kisslinux/repo/releases/download/$ver
kurl=https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$kver.tar.xz
dev=/dev/sda
dest=/mnt
cwd=$(pwd)

printf "o\nw\n" | fdisk $dev
mkfs.ext4 -F $dev
mount $dev $dest
wget "$url/kiss-chroot-$ver.tar.xz" -P "$HOME"
tar xvf "$HOME/kiss-chroot-$ver.tar.xz" -C $dest --strip-components 1
mkdir -p $dest/usr/src
wget $kurl -P $dest/usr/src
cd $dest/usr/src && tar xvf linux-*
cd linux-* && cp $cwd/files/.config ./ && cp $cwd/files/kernel-no-perl.patch ./
cp $cwd/files/.profile $dest/root
cp $cwd/files/bootstrap.sh $dest/root
cp $cwd/files/grub $dest/root
$dest/bin/kiss-chroot $dest /root/bootstrap.sh
