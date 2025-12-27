#!/bin/bash
# Todo
# Use gum log

source ./cfg_install.sh

echo "Misato Installer for Void Linux, V.0.1.0"

if [[ $CF_DISKS == "Automatic (Best effort)" ]]; then
    echo "Using best effort partitioning scheme..."
    echo -e "label: gpt\n1G,1G,U\n,,L" | sfdisk /dev/sda

    echo "Creating filesystems..."
    mkfs.vfat /dev/sda1
    mkfs.ext4 /dev/sda2
    mount /dev/sda2 /mnt
    mkdir -p /mnt/boot/efi
    mount /dev/sda1 /mnt/boot/efi/
else
    echo "You have selected to partition disks and install filesystems manually."
    echo "You will now be dropped onto a bash shell."
    echo "Available tools include: fdisk, cfdisk, mkfs.ext4, mkfs.vfat"
    echo "When you are done run 'exit'."
    bash
fi

echo "Installing base system..."
REPO=https://repo-default.voidlinux.org/current/musl
ARCH=x86_64-musl
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO" base-system

echo "Generating fstab..."
xgenfstab -U /mnt > /mnt/etc/fstab

echo "Entering chroot..."
xchroot /mnt /bin/bash -c "
    echo '$CF_HOSTNAME' > /etc/hostname
    sed -i '/^#KEYMAP=\"es\"/c\KEYMAP=\"$CF_KEYBOARD\"' /etc/rc.conf
    ln -sf $CF_TIME /etc/localtime
    echo -e \"$CF_PASSWD\n$CF_PASSWD\" | passwd
    ln -s /etc/sv/dhcpcd /var/service/
    xbps-install -S grub-x86_64-efi
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=\"Misato\"
    xbps-reconfigure -fa
    useradd -m -g wheel $CF_USERNAME
    echo -e \"$CF_USERPASSWD\n$CF_USERPASSWD\" | passwd
"

echo "Installation complete!"
echo "Rebooting in 3..."
sleep 1
echo "2..."
sleep 1
echo "1..."
sleep 1
umount -R /mnt
shutdown -r now
