#!/bin/bash
if [[ $# -ne 2 ]]; then
  echo 'usage: ./wifi.sh <SSID> <PW>'
  exit 1
fi
IFACE=$(iw dev | awk '$1=="Interface"{print $2}')
wpa_passphrase "$1" "$2" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant-${IFACE}.conf
sudo ln -s /etc/sv/wpa_supplicant /var/service/
sudo sv restart dhcpcd
sudo sv restart wpa_supplicant
