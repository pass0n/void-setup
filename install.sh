#!/bin/sh
#
# MY PERSONAL INSTALLATION SETUP FOR VOID LINUX.
#
# author: pass0n

cryptsetup luksOpen /dev/sda2 lvm
vgchange -ay

wipefs -a /dev/sda1
wipefs -a /dev/mapper/lvm-volRoot
wipefs -a /dev/mapper/lvm-volSwap

mkfs.vfat -F32 /dev/sda1
mkfs.ext4 -L root /dev/mapper/lvm-volRoot
mkswap /dev/mapper/lvm-volSwap

mount /dev/mapper/lvm-volRoot /mnt
for dir in dev proc sys run; do
    mkdir -p /mnt/$dir
    mount --rbind /$dir /mnt/$dir
    mount --make-rslave /mnt/$dir
done
mount --mkdir /dev/mapper/lvm-volHome /mnt/home
mount --mkdir /dev/sda1 /mnt/boot/efi

mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

REPO="https://repo-default.voidlinux.org/current"
xbps-install -Syuv -R $REPO -r /mnt base-system base-devel lvm2 cryptsetup grub-x86_64-efi neovim git

cp -r ./etc/* /mnt/etc

xchroot /mnt /bin/bash <<EOF

    chown root:root /
    chmod 755 /
    chmod 000 /key.bin
    cp /home/key.bin /

    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="void_grub" /dev/sda
    xbps-reconfigure -fa

    git clone git@github.com:pass0n/void-setup.git /home/
EOF
xchroot /mnt passwd root

xchroot /mnt /bin/bash <<EOF
    cd /home/dotfiles/
    chmod +x config.sh
    ./config.sh
    cd ..
    rm -r dotfiles
EOF
