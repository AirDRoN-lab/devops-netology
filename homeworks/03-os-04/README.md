### 1) На лекции мы познакомились с node_exporter. В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для node_exporter: поместите его в автозагрузку, предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на systemctl cat cron), удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

Файл конфигураии юнита systemd:

	vagrant@vagrant:~/node_exporter$ cat /etc/systemd/system/node_exporter.service
	[Unit]
	Description=Node_Exporter Settings Service
	After=network.target
	[Service]
	EnvironmentFile=/home/vagrant/node_exporter/node_exporter.collect
	Type=simple
	User=root
	ExecStart=/home/vagrant/node_exporter/node_exporter $EXTRA_OPTS
	[Install]
	WantedBy=multi-user.target


Файл дополнительных опций node_exporter:

	vagrant@vagrant:~/node_exporter$ cat /home/vagrant/node_exporter/node_exporter.collect
	EXTRA_OPTS="--collector.cpu --collector.diskstats --collector.loadavg --collector.meminfo --collector.netstat --collector.stat --collector.thermal_zone"

Node_Exporter запущен (после ребута):

	vagrant@vagrant:~/node_exporter$ systemctl list-units | grep Node_Exporter
		node_exporter.service                                                                    loaded active running   Node_Exporter Settings Service

	root@vagrant:~# systemctl status node_exporter
	● node_exporter.service - Node_Exporter Settings Service
		Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
		Active: active (running) since Sun 2021-12-05 09:56:12 UTC; 7h ago
		Main PID: 649 (node_exporter)
		Tasks: 3 (limit: 2279)
		Memory: 13.5M
		CGroup: /system.slice/node_exporter.service
				└─649 /home/vagrant/node_exporter/node_exporter --collector.cpu --collector.diskstats --collector.loadavg --collector.meminfo --collec>

	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:115 level=info collector=thermal_zone
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:115 level=info collector=time
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:115 level=info collector=timex
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:115 level=info collector=udp_queues
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:115 level=info collector=uname
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:115 level=info collector=vmstat
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:115 level=info collector=xfs
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:115 level=info collector=zfs
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.300Z caller=node_exporter.go:199 level=info msg="Listening on" address=:9100
	Dec 05 09:56:12 vagrant node_exporter[649]: ts=2021-12-05T09:56:12.304Z caller=tls_config.go:195 level=info msg="TLS is disabled." http2=false

### 2) Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.
Думаю можно остановиться на следующих опциях node_exporter:
	--collector.cpu
	--collector.diskstats
	--collector.loadavg
	--collector.meminfo
	--collector.netstat
	--collector.stat
	--collector.thermal_zone


### 3) Установите в свою виртуальную машину Netdata. Воспользуйтесь готовыми пакетами для установки (sudo apt install -y netdata). После успешной установки: в конфигурационном файле /etc/netdata/netdata.conf в секции [web] замените значение с localhost на bind to = 0.0.0.0, добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте vagrant reload: config.vm.network "forwarded_port", guest: 19999, host: 19999. После успешной перезагрузки в браузере на своем ПК (не в виртуальной машине) вы должны суметь зайти на localhost:19999. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

Netdata поднялась, страница открылась (скриншот во вложении). Изначально у netdata нет секции [web], соответсвенно необходимо добавить (а не заменить).
Перечень счетчиков крайне удивил, полезный инструмент.

### 4) Можно ли по выводу dmesg понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

Да, можно

	[    0.000000] DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
	[    0.000000] Hypervisor detected: KVM
	[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
	[    0.000001] kvm-clock: cpu 0, msr 3a801001, primary cpu clock
	[    0.000001] kvm-clock: using sched offset of 7464657124 cycles

### 5) Как настроен sysctl fs.nr_open на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (ulimit --help)?

Это лимит на кол-во файловых дискрипторов (max open files):

	vagrant@vagrant:~$ sudo sysctl -a | grep fs.nr_open
	fs.nr_open = 1048576

Кроме системного параметра, значение ограничичвает еще и ulimit -n (the maximum number of open file descriptors):

	vagrant@vagrant:~$ ulimit -n -H
	1048576

### 6) Запустите любой долгоживущий процесс (не ls, который отработает мгновенно, а, например, sleep 1h) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через nsenter. Для простоты работайте в данном задании под root (sudo -i). Под обычным пользователем требуются дополнительные опции (--map-root-user) и т.д.

Да, получилось сделать sleep с PID1 в отдельном namespace:

	root@vagrant:~# nsenter --target 4286 --pid --mount
	root@vagrant:/# ps aux
	USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
	root           1  0.0  0.0   8076   588 pts/3    S+   11:02   0:00 /usr/bin/sleep 1h
	root           2  0.0  0.4   9836  4076 pts/0    S    11:03   0:00 -bash
	root          11  0.0  0.3  11492  3448 pts/0    R+   11:03   0:00 ps aux

### 7) Найдите информацию о том, что такое :(){ :|:& };:. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов dmesg расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

Это форк бомба. Функция : порождает сама себя и делает это в фоновом режиме. В итоге кол-во процессов стремительно растет. Кол-во процессов в системе лимитировано и задается ulimit -u (у меня значение 7598). 

	root@vagrant:/# ulimit -u -H
	7598
	
Предотвращает размножение функции cgroup. Сообщение из dmesg:

	[12132.915260] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope