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
