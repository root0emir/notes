#!/bin/bash

## iptables rules clean
iptables -F
iptables -t nat -F

## routing traffic tor
iptables -t nat -A OUTPUT -d 127.0.0.1 -j RETURN
iptables -t nat -A OUTPUT -m owner --uid-owner debian-tor -j RETURN

## routing all dns request to tor - port 9053 (Tor DNS port)
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 9053

## routing all tcp requests to tor (9050 is default SOCKS proxy port for Tor)
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports 9050

## access
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

## access
iptables -A OUTPUT -m owner --uid-owner debian-tor -j ACCEPT

## prevent dns leaks
iptables -A OUTPUT -p udp --dport 53 -j REJECT

## disable all other traffic
iptables -A OUTPUT -j REJECT

# testing Tor connection to ensure it's working 
if curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/ | grep -q "Congratulations"; then
  echo "Tor connection successful!"
else
  echo "Tor connection failed."
fi





    ALTERNATİF DAHA GUVENLI TEST EDILMEDI:





    #!/bin/bash

## iptables rules temizleme
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

echo "Tüm iptables kuralları temizlendi."

## Yerel loopback'e izin ver
iptables -t nat -A OUTPUT -d 127.0.0.1 -j RETURN
iptables -t nat -A OUTPUT -m owner --uid-owner debian-tor -j RETURN

## Tüm DNS isteklerini Tor’un 9053 portuna yönlendir
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 9053

## Tüm TCP trafiğini Tor’un 9050 SOCKS portuna yönlendir
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports 9050

## İzin verilen bağlantılar
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner debian-tor -j ACCEPT

## DNS sızıntılarını önleme
iptables -A OUTPUT -p udp --dport 53 -j REJECT
iptables -A OUTPUT -p udp -j REJECT  # UDP trafiğini tamamen kapat

## Diğer tüm trafiği engelle (Tor hariç)
iptables -A OUTPUT -j REJECT

echo "iptables kuralları güncellendi."

## Tor bağlantısını test et
if curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/ | grep -q "Congratulations"; then
  echo "[SUCCESS] Tor bağlantısı başarılı!"
  logger "[SUCCESS] Tor bağlantısı başarılı!"
else
  echo "[ERROR] Tor bağlantısı başarısız!"
  logger "[ERROR] Tor bağlantısı başarısız!"
fi
