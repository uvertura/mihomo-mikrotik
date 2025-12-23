# Mihomo for Mikrotik

Сборка: docker buildx build -t volkhonsky/mihomo-eustratius:latest --push --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v5 .

***[!!!] после установки, необходимо проверить правила на межсетевом экране***



#### Не забыть добавить правила:

Принудительно отключить DoH в Firefox
```mikrotik
/ip/dns/static
add name=use-application-dns.net type=NXDOMAIN
```

Перенаправить все DNS запросы на роутер (опционально можно добавить in-interface-list=LAN)
```mikrotik
/ip/firewall/nat
add chain=dstnat protocol=udp dst-port=53 action=redirect to-ports=53
add chain=dstnat protocol=tcp dst-port=53 action=redirect to-ports=53
```

Блокировать DoT запросы, DoH из списка doh-domains и сервисы iCloud Private Relay
(отключает Doh и DoT(?) в Chrome и Safari)
```mikrotik
/ip firewall filter
add chain=forward protocol=tcp dst-port=443 dst-address-list=doh-domains action=drop comment="Block public DoH"
add chain=forward tls-host=mask.icloud.com action=reject protocol=tcp comment="Block iCloud Private Relay"
add chain=forward tls-host=mask-h2.icloud.com action=reject protocol=tcp comment="Block iCloud Private Relay"

# Блокировка DoT приводит к не стабильной работе Firefox
# add chain=forward protocol=tcp dst-port=853 action=reject comment="Block DoT"
```
