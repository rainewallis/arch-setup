#!/usr/bin/env bash

# BEFORE RUNNING THIS SCRIPT:
# THE DISK MUST BE PARITIONED AND MOUNTED MANUALLY!!

# Get CPU Vendor
CPU_VENDOR=$( lscpu | grep Vendor | awk '{print $NF}' )
MICROCODE_PACKAGE=""
case "$CPU_VENDOR" in
    AuthenicAMD*) MICROCODE_PACKAGE="amd_ucode" ;;
    GenuineIntel*) MICROCODE_PACKAGE="intel_ucode";;
    *) echo "Unable to determine CPU vendor..." ;;
esac

# Install base system elements
pacstrap -K /mnt base base-devel linux linux-firmware sysfsutils usbutils e2fsprogs inetutils netctl vim less which man-db man-pages $MICROCODE_PACKAGE

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

# Install bootloader (source: https://arch.d3sox.me/installation/install-bootloader)
pacman -S grub os-prober efibootmgr dosfstools mtools gptfdisk fatresize
grub-install --target=x86_64-efi --bootloader-id=grub-uefi --efi-directory=/boot --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Set to correct timezone
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock -systohc

# Set locale
echo "en_GB.UTF-8 UTF-8" >> /etc/local.gen
locale-gen

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf

# Save info for setup script
echo "CPU_VENDOR=$CPU_VENDOR" > /root/.arch-install-vars.tmp

passwd
