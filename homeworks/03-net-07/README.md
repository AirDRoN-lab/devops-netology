### 1) Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?
Linux: можно использовать ip address, ifconfig (входит в пакет net-tools)
Win: ipconfig 

### 2)Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?
Используется протокол lldp (также есть пропириетарные аналоги cdp, hdp).
Установка пакета в Debian:

	vagrant@vagrant:~$ sudo apt install lldpd
	
Просмотр соседей:

	vagrant@vagrant:~$ sudo lldpctl

Также соседа обнаружить (косвенно) можно в arp таблице:

	vagrant@vagrant:~$ arp -a
	? (10.0.2.3) at 52:54:00:12:35:03 [ether] on eth0
	_gateway (10.0.2.2) at 52:54:00:12:35:02 [ether] on eth0
	vagrant@vagrant:~$ ip neigh
	10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 DELAY
	10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE

### 3)Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.
Для разделение L2 домена на виртуальные подсети используется технология IEEE 802.1Q (принадлежность к VLAN). Для работы с vlan необходим пакет vlan (хотя deprecated).

	vagrant@vagrant:/etc/network$ sudo vconfig add eth0 1010
	vagrant@vagrant:/etc/network$ ifconfig eth0.1010
	eth0.1010: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
			inet6 fe80::a00:27ff:fe73:60cf  prefixlen 64  scopeid 0x20<link>
			ether 08:00:27:73:60:cf  txqueuelen 1000  (Ethernet)
			RX packets 0  bytes 0 (0.0 B)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 10  bytes 796 (796.0 B)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

Конфигурацию лучше прописывать через netplan, например:

	vagrant@vagrant:/etc/netplan$ cat 01-netcfg.yaml
	network:
			version: 2
		ethernets:
			eth0:
				dhcp4: true
		vlans:
			vlan10:
				id: 10
				link: eth0
				addresses: [11.11.11.11/24]

Применяем так:

	vagrant@vagrant:/etc/netplan$ sudo netplan apply
	vagrant@vagrant:/etc/netplan$ ip a show vlan10
		4: vlan10@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
		link/ether 08:00:27:73:60:cf brd ff:ff:ff:ff:ff:ff
		inet 11.11.11.11/24 brd 11.11.11.255 scope global vlan10
		valid_lft forever preferred_lft forever
		inet6 fe80::a00:27ff:fe73:60cf/64 scope link
		valid_lft forever preferred_lft forever
				
### 4)Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.

Конфигурация netplan ниже. Режим агрегации указан в разделе mode (в нашем случае active-backup). Возможные значения balance-rr (дефолт),
active-backup,  balance-xor, broadcast, 802.3ad, balance-tlb и balance-alb.  Для OpenVSwitch возможны значения active-backup и дополнительно balance-tcp and balance-slb.

Для балансировки нагрузки есть следующие опции:
transmit-hash-policy (применимо только для balance-xor, 802.3ad and balance-tlb modes). Возможные варианты значений: layer2, layer3+4, layer2+3, encap2+3, and encap3+4. 

	golodnikov@goofy:/etc/netplan$ cat /etc/netplan/00-installer-config.yaml
	network:
	  ethernets:
		eno1:
		  addresses:
		  - 83.149.49.69/28
		  gateway4: 83.149.49.65
		  nameservers:
			addresses:
			- 8.8.8.8
			search: []
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


### 5)Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.

	В сети с маской /29 адресов 8.
	Из сети с маской /24 можно получить 32 подсети /29.
	Примеры /29 в подсети 10.10.10.0/24: 10.10.10.0/29, 10.10.10.8/29, 10.10.10.248/29
	
### 6)Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.

	Можно взять подсеть Из диапазона 100.64.0.0/10. Для нужд задачи подойдет подсеть 100.64.0.0/26.

### 7)Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?

Linux: просмотр ARP таблицы:

	vagrant@vagrant:~$ arp -a
	? (10.0.2.3) at 52:54:00:12:35:03 [ether] on eth0
	_gateway (10.0.2.2) at 52:54:00:12:35:02 [ether] on eth0
	vagrant@vagrant:~$ ip neigh
	10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 DELAY
	10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
	
Linux: уделение конкретного хоста:

	vagrant@vagrant:/etc/netplan$ sudo arp -d 10.0.2.3
	vagrant@vagrant:/etc/netplan$ sudo ip neigh del 10.0.2.3 dev eth0
	
Linux: полное очищение ARP таблицы можно сделать через ip:

	vagrant@vagrant:/etc/netplan$ sudo ip neigh flush all
	
Win: просмотр ARP таблицы:

	PS C:\Users\dmgol> arp -a

	Интерфейс: 192.168.8.106 --- 0x13
	адрес в Интернете      Физический адрес      Тип
	192.168.8.1           cc-2d-e0-0f-0f-33     динамический
	192.168.8.2           00-11-32-b8-42-3e     динамический
	192.168.8.3           58-8b-f3-6b-62-04     динамический
	192.168.8.60          3c-cd-93-0f-19-94     динамический
  
Win: очищение и уделение конкретного хоста:

	PS C:\Users\dmgol> arp -d 192.168.8.3
	PS C:\Users\dmgol> arp -d *