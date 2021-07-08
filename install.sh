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

#ver=2021.5-1
ver=2021.7-4
#url=https://github.com/kiss-community/repo/releases/download/$ver
url=https://github.com/kisslinux/repo/releases/download/$ver
dev=/dev/sda
printf "o\nw\n" | fdisk $dev
mkfs.ext4 -F $dev
mount /dev/sda /mnt
wget "$url/kiss-chroot-$ver.tar.xz" -P "$HOME"
tar xvf "$HOME/kiss-chroot-$ver.tar.xz" -C /mnt --strip-components 1
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.47.tar.xz -P /mnt/usr/src
/mnt/bin/kiss-chroot /mnt <<"EOT"
export CFLAGS="-O1 -pipe -march=native"
export CXXFLAGS="-O1 -pipe -march=native"
export MAKEFLAGS="-j1"
export KISS_PROMPT=0
export KISS_PATH=/root/repos/repo/core:/root/repos/repo/extra
mkdir /root/repos
cd /root/repos
#git clone https://github.com/kiss-community/repo
git clone https://github.com/kisslinux/repo
kiss update
kiss update
cd /var/db/kiss/installed && kiss build *
kiss b e2fsprogs && kiss i e2fsprogs
kiss b dosfstools && kiss i dosfstools
kiss b eudev && kiss i eudev
kiss b libelf && kiss i libelf
kiss b ncurses && kiss i ncurses
kiss b openssh && kiss i openssh
#kiss b perl && kiss i perl
kiss b grub && kiss i grub
kiss b dhcpcd && kiss i dhcpcd
cd /usr/src
tar xvf /usr/src/linux-*
cd linux-*
curl https://raw.githubusercontent.com/mcpcpc/kinode/master/.config > .config
make -j1
make INSTALL_MOD_STRIP=1 modules_install
make install
mv /boot/vmlinuz /boot/vmlinuz-5.10.47
mv /boot/System.map /boot/System.map-5.10.47
echo -e "/dev/sda\t/\text4\terrors=remount-ro\t0 1" > /etc/fstab
cd /etc/default
mv grub grub.bak
curl https://raw.githubusercontent.com/mcpcpc/kinode/master/grub > grub
grub-install --force /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
kiss b baseinit && kiss i baseinit
ln -s /etc/sv/udevd/ /var/service
ln -s /etc/sv/sshd/ /var/service
ls -s /etc/sv/dhcpcd/ /var/service
passwd root
echo $$
EOT
