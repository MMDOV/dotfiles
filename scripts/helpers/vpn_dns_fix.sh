#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

mkdir -p /etc/NetworkManager/conf.d
printf "[main]\ndns=systemd-resolved\n" >/etc/NetworkManager/conf.d/dns.conf

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

systemctl restart NetworkManager systemd-resolved

cat <<'EOF' >/etc/NetworkManager/dispatcher.d/90-xvpn-dns
#!/bin/sh
if [ "$1" = "xvpn-tun0" ] && [ "$2" = "up" ]; then
    sleep 2
    resolvectl dns xvpn-tun0 1.1.1.1 8.8.8.8
    resolvectl domain xvpn-tun0 '~.'
    resolvectl default-route xvpn-tun0 yes
fi
EOF

cat <<'EOF' >/etc/NetworkManager/dispatcher.d/90-tun0-dns
#!/bin/sh
if [ "$1" = "tun0" ] && [ "$2" = "up" ]; then
    sleep 2
    resolvectl dns tun0 1.1.1.1 8.8.8.8
    resolvectl domain tun0 '~.'
    resolvectl default-route tun0 yes
fi
EOF

chmod +x /etc/NetworkManager/dispatcher.d/90-xvpn-dns
chmod +x /etc/NetworkManager/dispatcher.d/90-tun0-dns

systemctl enable --now NetworkManager-dispatcher.service
