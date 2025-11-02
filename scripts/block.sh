for con in $(nmcli -t -f NAME connection show); do
  sudo nmcli connection modify "$con" \
    ipv4.dns "1.1.1.3 1.0.0.3" \
    ipv4.ignore-auto-dns yes \
    ipv6.dns "2606:4700:4700::1113 2606:4700:4700::1003" \
    ipv6.ignore-auto-dns yes
done
