### 1) Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP

Маршруты до публичного IPv6 адреса ниже. По непонятным причинам маршрутизатор не мщет bgp маршурт для IPv6 хоста и требует указание маски.
Логично , что при указании маски 128 префикса нет в таблице маршрутизации. Соответсвенно, был введен поиск маршурта для префикса /38, который провайдер анонсирует апстримам (префикс был найден на ripe.net, как route6 обьект).
	
	telnet route-views.routeviews.org
	Username: rviews

	route-views>show ipv6 route 2a02:2698:5022:85c0:9cd6:4d87:6972:5263
		Routing entry for 2A02:2698:5022::/47
		Known via "bgp 6447", distance 20, metric 0, type external
		Route count is 1/1, share count 0
			Routing paths:
			2001:470:0:1A::1
		MPLS label: nolabel
		Last updated 7w0d ago
		
	route-views>show bgp ipv6 unicast 2a02:2698:5022:85c0:9cd6:4d87:6972:5263
	% Incomplete command.
	
	route-views>    show bgp ipv6 unicast 2a02:2698:5022:85c0:9cd6:4d87:6972:5263/128
	% Network not in table	

	route-views>show bgp ipv6 unicast 2a02:2698:5000::/38
	BGP routing table entry for 2A02:2698:5000::/38, version 561455948
	Paths: (13 available, best #13, table default)
	  Not advertised to any peer
	  Refresh Epoch 1
	  101 174 1299 9049 43478
		2001:1860::223 from 2001:1860::223 (209.124.176.223)
		  Origin IGP, localpref 100, valid, external
		  Community: 101:20100 101:20110 101:22100 174:21000 174:22013
		  Extended Community: RT:101:22100
		  path 7FE188EC7F98 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  20130 6939 9049 43478
		2620:0:2250::FF0B from 2620:0:2250::FF0B (140.192.8.16)
		  Origin IGP, localpref 100, valid, external
		  path 7FE039B2D310 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  7018 1299 9049 43478
		2001:1890:111D:1::63 from 2001:1890:111D:1::63 (12.0.1.63)
		  Origin IGP, localpref 100, valid, external
		  Community: 7018:5000 7018:37232
		  path 7FE09F2FF708 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  57866 9002 9049 43478
		2A00:A7C0:E20A::17 from 2A00:A7C0:E20A::17 (37.139.139.17)
		  Origin IGP, metric 0, localpref 100, valid, external
		  Community: 9002:0 9002:64667
		  path 7FE0858536D8 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  20912 6939 9049 43478
		2001:40D0::126 from 2001:40D0::126 (212.66.96.126)
		  Origin IGP, localpref 100, valid, external
		  Community: 20912:65016
		  path 7FE0B1EB4F58 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 2
	  3303 6939 9049 43478
		2001:918:0:5::1 from 2001:918:0:5::1 (138.187.128.158)
		  Origin IGP, localpref 100, valid, external
		  Community: 3303:1006 3303:1021 3303:1030 3303:3067 6939:7040 6939:8752 6939:9002
		  path 7FE098C0E678 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  1351 174 1299 9049 43478
		2620:104:E000:1000::3 from 2620:104:E000:1000::3 (132.198.255.253)
		  Origin IGP, localpref 100, valid, external
		  path 7FE1142EB748 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 2
	  24441 6939 9049 43478
		2404:CC00:1::4 from 2404:CC00:1::1 (202.93.8.242)
		  Origin IGP, localpref 100, valid, external
		  path 7FE0361F4A50 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  49788 1299 9049 43478
		2A02:D140:1::60 from 2A02:D140:1::60 (91.218.184.60)
		  Origin IGP, localpref 100, valid, external
		  Community: 1299:30000
		  path 7FE00C62C268 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  8283 1299 9049 43478
		2A02:898:0:300::3 from 2A02:898:0:300::3 (94.142.247.3)
		  Origin IGP, metric 0, localpref 100, valid, external
		  Community: 1299:30000 8283:1 8283:101 8283:103
		  unknown transitive attribute: flag 0xE0 type 0x20 length 0x24
			value 0000 205B 0000 0000 0000 0001 0000 205B
				  0000 0005 0000 0001 0000 205B 0000 0005
				  0000 0003
		  path 7FE005A54D98 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  4901 6079 9002 9049 43478
		2620:118:5007:FFFF::FFFF from 2620:118:5007:FFFF::FFFF (162.250.137.254)
		  Origin IGP, localpref 100, valid, external
		  Community: 65000:10100 65000:10300 65000:10400
		  path 7FE046148FC8 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  701 1299 9049 43478
		2600:803::15 from 2600:803::15 (137.39.3.55)
		  Origin IGP, localpref 100, valid, external
		  Community: 701:333 701:1020
		  path 7FE04D073660 RPKI State valid
		  rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  6939 9049 43478
		2001:470:0:1A::1 from 2001:470:0:1A::1 (216.218.252.164)
		  Origin IGP, localpref 100, valid, external, best
		  path 7FE0284CB798 RPKI State valid
		  rx pathid: 0, tx pathid: 0x0	
			

### 2) Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.

Создан интерфейс loop0 с IP 1.1.1.1/32, созданы два марршрута для подсетей 2.2.2.0/24 и 3.3.3.0/24. Список коанд ниже.


	$ cat /etc/netplan/00-installer-config.yaml
	network:
	  ethernets:
		eno1:
		  addresses:
		  - 81.149.44.69/28
		  gateway4: 81.149.44.65
		  nameservers:
			addresses:
			- 8.8.8.8
			search: []
		  routes: 
			- to:  2.2.2.0/24
			  via: 81.149.44.66
			- to:  3.3.3.0/24
			  via: 81.149.44.67
		eno2:
		  dhcp4: no
		eno3:
		  dhcp4: no
		eno4:
		  dhcp4: no
	  version: 2
	  bonds:
		bond0:
		  interfaces:
		  - eno3
		  - eno4
		  parameters:
			mode: active-backup
			primary: eno3
	  bridges:
		loop0:
		  addresses:
		  - 1.1.1.1/32


	$ ip route get 8.8.8.8
	8.8.8.8 via 81.149.44.65 dev eno1 src 83.149.49.69 uid 1000
		cache

	$ ip route get 1.1.1.1
	local 1.1.1.1 dev lo src 1.1.1.1 uid 1000
		cache <local>
		
	$ ip route get 2.2.2.2
	2.2.2.2 via 81.149.44.66 dev eno1 src 83.149.49.69 uid 1000
		cache
		
	$ netstat -rn
	Kernel IP routing table
	Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
	0.0.0.0         81.149.44.65    0.0.0.0         UG        0 0          0 eno1
	2.2.2.0         81.149.44.66    255.255.255.0   UG        0 0          0 eno1
	3.3.3.0         81.149.44.67    255.255.255.0   UG        0 0          0 eno1
	10.222.222.0    0.0.0.0         255.255.255.0   U         0 0          0 wg0
	81.149.44.64    0.0.0.0         255.255.255.240 U         0 0          0 eno1
	172.17.0.0      0.0.0.0         255.255.0.0     U         0 0          0 docker0

	$ ip route list
	default via 83.149.49.65 dev eno1 proto static
	2.2.2.0/24 via 83.149.49.66 dev eno1 proto static
	3.3.3.0/24 via 83.149.49.67 dev eno1 proto static
	10.222.222.0/24 dev wg0 proto kernel scope link src 10.222.222.1
	81.149.44.64/28 dev eno1 proto kernel scope link src 81.149.44.69
	172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown

	$ ip -br a show dev loop0
	loop0            UNKNOWN        1.1.1.1/32 fe80::c01f:90ff:fe94:6413/64


### 3) Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.

Открыты порты 22 и 53. Это порты для доступа по SSH и DNS (systemd) соответсвенно. В первом случае порт слушает на всех интерфейсах (0.0.0.0), во втором случае только на lo интефоейсе. 

	$ ss -tnlp
	State          Recv-Q         Send-Q                 Local Address:Port                 Peer Address:Port        Process
	LISTEN         0              4096                   127.0.0.53%lo:53                        0.0.0.0:*            users:(("systemd-resolve",pid=2680293,fd=13))
	LISTEN         0              128                          0.0.0.0:22                        0.0.0.0:*            users:(("sshd",pid=189490,fd=3))
	LISTEN         0              128                             [::]:22                           [::]:*            users:(("sshd",pid=189490,fd=4))


### 4) Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?

Открытые UDP сокеты ниже. 

	dgolodnikov@goofy:/etc/netplan$ sudo ss -unap
	State          Recv-Q         Send-Q                 Local Address:Port                  Peer Address:Port        Process
	UNCONN         0              0                      127.0.0.53%lo:53                         0.0.0.0:*           users:(("systemd-resolve",pid=2680293,fd=12))
	UNCONN         0              0                            0.0.0.0:51820                      0.0.0.0:*
	UNCONN         0              0                            0.0.0.0:5353                       0.0.0.0:*            users:(("avahi-daemon",pid=122687,fd=12))
	UNCONN         0              0                            0.0.0.0:41492                      0.0.0.0:*            users:(("avahi-daemon",pid=122687,fd=14))
	UNCONN         0              0                               [::]:33333                         [::]:*            users:(("avahi-daemon",pid=122687,fd=15))
	UNCONN         0              0                               [::]:51820                         [::]:*
	UNCONN         0              0                               [::]:5353                          [::]:*            users:(("avahi-daemon",pid=122687,fd=13))


### 5) Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали.

Во вложении мнимая домашняя сеть. https://www.diagrams.net/ хороший инструмент для оперативной отрисовки схем.