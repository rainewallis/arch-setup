#!/usr/bin/env bash

# Enable network services
systemctl enable systemd-networkd
systemctl enable systemd-resolved

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

pacman -S networkmanager
systemctl enable NetworkManager

# Get graphics vendor
GRAPHICS_VENDOR=$( lshw -C display | grep vendor | awk -F: '{print$2}' )
