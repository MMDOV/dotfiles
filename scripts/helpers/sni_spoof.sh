#!/bin/bash

iptables -t mangle -I OUTPUT -d 104.17.148.22 -p tcp --dport 443 -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 -j NFQUEUE --queue-num 200 --queue-bypass

nfqws --qnum=200 --dpi-desync=fake --dpi-desync-fooling=badseq --dpi-desync-fake-tls-mod=sni=www.speedtest.net &
NFQWS_PID=$!

socat TCP4-LISTEN:40443,bind=0.0.0.0,fork,reuseaddr TCP4:104.17.148.22:443

kill $NFQWS_PID
iptables -t mangle -D OUTPUT -d 104.17.148.22 -p tcp --dport 443 -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 -j NFQUEUE --queue-num 200 --queue-bypass
