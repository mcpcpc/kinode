#!/bin/sh -e
mkdir /root/repos
cd /root/repos && git clone https://github.com/kisslinux/repo
kiss u && kiss u
cd /var/db/kiss/installed && kiss b *
kiss b e2fsprogs
kiss b dosfstools
kiss b eudev
kiss b libelf
kiss b openssh
kiss b grub
kiss b dhcpcd
cd /usr/src/linux-* && patch -p1 < kernel-no-perl.patch
make -j1
make INSTALL_MOD_STRIP=1 modules_install
make install
mv /boot/vmlinuz /boot/vmlinuz-5.10.47
mv /boot/System.map /boot/System.map-5.10.47
cd /etc/default
mv grub grub.bak
mv /root/grub ./
grub-install --force /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
kiss b baseinit && kiss i baseinit
ln -s /etc/sv/udevd/ /var/service
ln -s /etc/sv/sshd/ /var/service
ls -s /etc/sv/dhcpcd/ /var/service
