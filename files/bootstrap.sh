#!/bin/sh -e
source /root/.profile
mkdir /root/repos
cd /root/repos && git clone https://github.com/kisslinux/repo
kiss update && kiss update
cd /var/db/kiss/installed && kiss build *
kiss b e2fsprogs && kiss i e2fsprogs
kiss b dosfstools && kiss i dosfstools
kiss b eudev && kiss i eudev
kiss b libelf && kiss i libelf
kiss b openssh && kiss i openssh
kiss b grub && kiss i grub
kiss b dhcpcd && kiss i dhcpcd
cd /usr/src/linux-* && patch -p1 < kernel-no-perl.patch
make -j1
make INSTALL_MOD_STRIP=1 modules_install
make install
mv /boot/vmlinuz /boot/vmlinuz-5.10.47
mv /boot/System.map /boot/System.map-5.10.47
cd /etc/default
mv grub grub.bak
mv /root/grub ./
#curl https://raw.githubusercontent.com/mcpcpc/kinode/master/files/grub > grub
grub-install --force /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
kiss b baseinit && kiss i baseinit
ln -s /etc/sv/udevd/ /var/service
ln -s /etc/sv/sshd/ /var/service
ls -s /etc/sv/dhcpcd/ /var/service
