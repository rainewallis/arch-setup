#!/usr/bin/env bash

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

# Enable network services
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl start systemd-resolved

# Find network interface name
INTERFACE_NAME=$( ip link | awk -F: '{print $2}' | grep -P 'enp[0-9]+s[0-9]+' | xargs )
cat <<EOF > /etc/systemd/network/dhcp.network
[Match]
Name=$INTERFACE_NAME

[Network]
DHCP=yes
EOF

cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
EOF

systemctl restart systemd-networkd

pacman -S bind lshw
yes_or_no "Would you like to install wifi control (iwd)" && pacman -S iwd

#pacman -S networkmanager bind
#systemctl enable NetworkManager
#systemctl start NetworkManager

# Get graphics vendor
GRAPHICS_VENDOR=$( lshw -C display | grep vendor | awk -F: '{print $2}' )
