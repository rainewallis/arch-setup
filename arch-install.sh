#!/usr/bin/env bash

# BEFORE RUNNING THIS SCRIPT:
# THE DISK MUST BE PARITIONED AND MOUNTED MANUALLY!!

## FUNCTIONS ##
function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0;;
            [Nn]*) echo "Aborted" ; return 1 ;;
        esac
    done
}

## SCRIPT ##

MOUNT_LOCATION="/mnt"

# Get CPU Vendor
CPU_VENDOR=$( lscpu | grep Vendor | awk '{print $NF}' )
MICROCODE_PACKAGE=""
case "$CPU_VENDOR" in
    AuthenticAMD*) MICROCODE_PACKAGE="amd-ucode" ;;
    GenuineIntel*) MICROCODE_PACKAGE="intel-ucode";;
    *) echo "Unable to determine CPU vendor..." ;;
esac

WIFI_DAEMON_PACKAGE=""
yes_or_no "Would you like to install the wifi daemon (iwd)" && WIFI_DAEMON_PACKAGE="iwd"

# Install base system elements
pacstrap -K $MOUNT_LOCATION base base-devel linux linux-firmware sysfsutils usbutils e2fsprogs inetutils netctl vim less which man-db man-pages git $MICROCODE_PACKAGE $WIFI_DAEMON_PACKAGE

genfstab -U $MOUNT_LOCATION >> $MOUNT_LOCATION/etc/fstab

# Change root command (must actually be prepended to each command, as is it will just drop you into bash)
CHROOT="arch-chroot $MOUNT_LOCATION"

# Install bootloader (source: https://arch.d3sox.me/installation/install-bootloader)
$CHROOT pacman -S grub os-prober efibootmgr dosfstools mtools gptfdisk fatresize
$CHROOT grub-install --target=x86_64-efi --bootloader-id=grub-uefi --efi-directory=/boot --recheck
$CHROOT grub-mkconfig -o /boot/grub/grub.cfg

# Set to correct timezone
$CHROOT ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
$CHROOT hwclock -systohc

# Set locale
$CHROOT echo "en_GB.UTF-8 UTF-8" | $CHROOT tee --append /etc/local.gen
$CHROOT locale-gen

$CHROOT echo "LANG=en_GB.UTF-8" | $CHROOT tee /etc/locale.conf
$CHROOT echo "KEYMAP=uk" | $CHROOT tee /etc/vconsole.conf

# Save info for setup script
$CHROOT echo "CPU_VENDOR=$CPU_VENDOR" | $CHROOT tee /root/.arch-install-vars.tmp

# Clone setup script
$CHROOT git clone https://github.com/rainewallis/arch-setup.git /root/arch-setup

$CHROOT passwd
