#Some part of the script is derived from here: https://techolay.net/sosyal/konu/linuxta-sadece-discord-icin-warp-calistirma-betigi.136745/
sudo systemctl enable systemd-resolved
RESOLVED_CONF="/etc/systemd/resolved.conf"
if ! grep -Fx "DNS=1.1.1.1 1.0.0.1" "$RESOLVED_CONF" > /dev/null; then
echo "DNS=1.1.1.1 1.0.0.1" | sudo tee -a "$RESOLVED_CONF"
fi

if ! grep -Fx "FallbackDNS=8.8.8.8 8.8.4.4" "$RESOLVED_CONF" > /dev/null; then
echo "FallbackDNS=8.8.8.8 8.8.4.4" | sudo tee -a "$RESOLVED_CONF"
fi
if ! grep -Fx "DNSOverTLS=yes" "$RESOLVED_CONF" > /dev/null; then
echo "DNSOverTLS=yes" | sudo tee -a "$RESOLVED_CONF"
fi
if ! grep -Fx "Domains=~." "$RESOLVED_CONF" > /dev/null; then
echo "Domains=~." | sudo tee -a "$RESOLVED_CONF"
fi
if ! grep -Fx "DNSSEC=yes" "$RESOLVED_CONF" > /dev/null; then
echo "DNSSEC=yes" | sudo tee -a "$RESOLVED_CONF"
fi
if ! grep -Fx "Cache=yes" "$RESOLVED_CONF" > /dev/null; then
echo "Cache=yes" | sudo tee -a "$RESOLVED_CONF"
fi

sudo rm -f /etc/resolv.conf
sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved



sudo tee /etc/yum.repos.d/cloudflare-warp.repo <<'EOF'
[cloudflare-warp]
name=Cloudflare Warp
baseurl=https://pkg.cloudflareclient.com/rpm
enabled=1
gpgcheck=1
gpgkey=https://pkg.cloudflareclient.com/pubkey.gpg
EOF

sudo dnf install cloudflare-warp
warp-cli registration new
warp-cli mode proxy 
warp-cli connect


sudo dnf install proxychains
PROXYCHAINS_CONF="/etc/proxychains.conf"

if [ -f "$PROXYCHAINS_CONF" ]; then
sudo sed -i '/^proxy_dns/s/^/#/' "$PROXYCHAINS_CONF"
sudo sed -i '/^socks4/s/^/#/' "$PROXYCHAINS_CONF"
if ! grep -Fx "socks5 127.0.0.1 40000" "$PROXYCHAINS_CONF" > /dev/null; then
echo "socks5 127.0.0.1 40000" | sudo tee -a "$PROXYCHAINS_CONF"
else
echo "socks5 127.0.0.1 40000 zaten mevcut. Atlanıyor..."
fi
else
echo "Hata: $PROXYCHAINS_CONF bulunamadı"
exit 1
fi


