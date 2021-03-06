### 1) Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.

Выполнено. Скриншот не публикуется из соображений секьюрности.

### 2) Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.

Выполнено. Скриншот не публикуется из соображений секьюрности. 

### 3) Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.

Пробрасываем порт на виртуалку. Дописываем в vagrantfile:

	config.vm.network "forwarded_port", guest: 443, host: 443

Ставим apache:

	vagrant@vagrant:~$ sudo apt 
	vagrant@vagrant:~$ sudo apt install apache2

Включаем модуль:

	vagrant@vagrant:~$ sudo a2enmod ssl
	Considering dependency setenvif for ssl:
	Module setenvif already enabled
	Considering dependency mime for ssl:
	Module mime already enabled
	Considering dependency socache_shmcb for ssl:
	Enabling module socache_shmcb.
	Enabling module ssl.

Ребут Apache2:

	vagrant@vagrant:~$ systemctl restart apache2
	
Генерируем сертификат и прикручиваем к хосту:

	vagrant@vagrant:~$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj "/C=RU/ST=Novosibirsk/L=Novosibirsk/O=Company Name/OU=Org/CN=www.example.com"
	
	vagrant@vagrant:~$  cat /etc/apache2/sites-available/81.111.49.70.conf
	<VirtualHost *:443>
        ServerName 81.111.49.70
        DocumentRoot /var/www/81.111.49.70
        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
	</VirtualHost>

	vagrant@vagrant:/etc/apache2/sites-available$ sudo systemctl restart apache2
	vagrant@vagrant:/etc/apache2/sites-available$ sudo a2ensite 81.111.49.70.conf
	vagrant@vagrant:/etc/apache2/sites-available$ sudo ss -tunl
	Netid         State          Recv-Q         Send-Q                  Local Address:Port                    Peer Address:Port         Process
	{...}
	tcp           LISTEN         0              511                                 *:443                                *:*
	{...}

Создаем index.html:

	sudo mkdir /var/www/81.111.49.70
	sudo touch /var/www/81.111.49.70/index.html && echo "<h1>it worked</h1>" | sudo tee /var/www/81.111.49.70/index.html

Проверяем:

	vagrant@vagrant:~$ curl https://localhost:443
	curl: (60) SSL certificate problem: self signed certificate

	vagrant@vagrant:~$ curl --insecure https://localhost:443
	<h1>it worked</h1>

### 4) Проверьте на TLS уязвимости произвольный сайт в интернете (кроме сайтов МВД, ФСБ, МинОбр, НацБанк, РосКосмос, РосАтом, РосНАНО и любых госкомпаний, объектов КИИ, ВПК ... и тому подобное).

Скачиваем sh скрипт testssl.sh c репозитория

	vagrant@ra:~$ git clone --depth 1 https://github.com/drwetter/testssl.sh.git
	vagrant@ra:~$ cd testssl

Зпускаем

	vagrant@ra:~/testssl/testssl.sh$ ./testssl.sh -U --sneaky https://www.netology.ru
	./testssl.sh: line 239: warning: setlocale: LC_COLLATE: cannot change locale (en_US.UTF-8): No such file or directory

	###########################################################
		testssl.sh       3.1dev from https://testssl.sh/dev/
		(6da72bc 2021-12-10 20:16:28 -- )

		  This program is free software. Distribution and
				 modification under GPLv2 permitted.
		  USAGE w/o ANY WARRANTY. USE IT AT YOUR OWN RISK!

		   Please file bugs @ https://testssl.sh/bugs/

	###########################################################

	Using "OpenSSL 1.0.2-chacha (1.0.2k-dev)" [~183 ciphers]
	on ra:./bin/openssl.Linux.x86_64
	(built: "Jan 18 17:12:17 2019", platform: "linux-x86_64")


	Testing all IPv4 addresses (port 443): 104.22.40.171 104.22.41.171 172.67.21.207
	--------------------------------------------------------------------------------------------------------------------------
	Start 2021-12-13 11:37:43        -->> 104.22.40.171:443 (www.netology.ru) <<--

	Further IP addresses:   172.67.21.207 104.22.41.171 2606:4700:10::6816:29ab 2606:4700:10::6816:28ab 2606:4700:10::ac43:15cf
	 rDNS (104.22.40.171):   --
	Service detected:       HTTP


	Testing vulnerabilities

	Heartbleed (CVE-2014-0160)                not vulnerable (OK), no heartbeat extension
	CCS (CVE-2014-0224)                       not vulnerable (OK)
	Ticketbleed (CVE-2016-9244), experiment.  not vulnerable (OK), no session tickets
	ROBOT                                     not vulnerable (OK)
	Secure Renegotiation (RFC 5746)           OpenSSL handshake didn't succeed
	Secure Client-Initiated Renegotiation     not vulnerable (OK)
	CRIME, TLS (CVE-2012-4929)                not vulnerable (OK)
	BREACH (CVE-2013-3587)                    no gzip/deflate/compress/br HTTP compression (OK)  - only supplied "/" tested
	POODLE, SSL (CVE-2014-3566)               not vulnerable (OK)
	TLS_FALLBACK_SCSV (RFC 7507)              Downgrade attack prevention supported (OK)
	SWEET32 (CVE-2016-2183, CVE-2016-6329)    VULNERABLE, uses 64 bit block ciphers
	FREAK (CVE-2015-0204)                     not vulnerable (OK)
	DROWN (CVE-2016-0800, CVE-2016-0703)      not vulnerable on this host and port (OK)
											   make sure you don't use this certificate elsewhere with SSLv2 enabled services
											   https://censys.io/ipv4?q=0E745E5E77A60345EB6E6B33B99A36286C2203D687F3377FBC685B2434518C53 could help you to find out
	LOGJAM (CVE-2015-4000), experimental      not vulnerable (OK): no DH EXPORT ciphers, no DH key detected with <= TLS 1.2
	BEAST (CVE-2011-3389)                     TLS1: ECDHE-RSA-AES128-SHA AES128-SHA ECDHE-RSA-AES256-SHA AES256-SHA DES-CBC3-SHA
											   VULNERABLE -- but also supports higher protocols  TLSv1.1 TLSv1.2 (likely mitigated)
	LUCKY13 (CVE-2013-0169), experimental     potentially VULNERABLE, uses cipher block chaining (CBC) ciphers with TLS. Check patches
	Winshock (CVE-2014-6321), experimental    not vulnerable (OK)
	RC4 (CVE-2013-2566, CVE-2015-2808)        no RC4 ciphers detected (OK)

### 5) Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.

Генерируем ключ

	vagrant@vagrant-iperf:~/.ssh$ ssh-keygen
	Generating public/private rsa key pair.

	{...}

	vagrant@vagrant-iperf:~/.ssh$ ll
	total 20
	drwx------ 2 vagrant vagrant 4096 дек 13 16:34 ./
	drwxr-xr-x 7 vagrant vagrant 4096 дек 13 16:33 ../
	-rw------- 1 vagrant vagrant 2610 дек 13 16:34 id_rsa
	-rw-r--r-- 1 vagrant vagrant  576 дек 13 16:34 id_rsa.pub
	-rw-r--r-- 1 vagrant vagrant  222 дек  9 14:32 known_hosts
	 
Копируем публичный ключ на удаленный сервер
	
	vagrant@vagrant-iperf:~/.ssh$ ssh-copy-id vagrant@83.111.84.71
	/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/vagrant/.ssh/id_rsa.pub"
	The authenticity of host '83.111.84.71 (83.111.84.71)' can't be established.

	{...}

	Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
	/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
	/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys

	Number of key(s) added: 1

	Now try logging into the machine, with:   "ssh 'vagrant@83.111.84.71'"
	and check to make sure that only the key(s) you wanted were added.

Пытаемся зайти на хост без ввода пароля.
	 
	vagrant@vagrant-testhost:~/.ssh$ ssh 83.111.84.71
	Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-89-generic x86_64)

	vagrant@vagrant:~$

### 6) Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.

Для доступа к удаленному хоступ можно использовать запись в /etc/hosts, так и запись в ssh_conf (и/или ~/.ssh/config)

	vagrant@vagrant:~$ mv id_rsa id_rsa_2
	vagrant@vagrant:~$ mv id_rsa.pub id_rsa_2.pub
	vagrant@vagrant:~$ cd ~/.ssh/
	vagrant@vagrant:~$ touch config
	vagrant@vagrant:~$ vim touch
	vagrant@vagrant:~$ cat config
	 
	Host testhost
			HostName 83.111.84.71
			Port 22
			User vagrant
			IdentityFile ~/.ssh/id_rsa_2

	vagrant@vagrant-testhost:~/.ssh$ ssh testhost
	Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-89-generic x86_64)

	vagrant@vagrant:~$

### 7) Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.

Скриншот во вложении, команда tcpdump ниже.

	vagrant@vagrant:~$ sudo tcpdump -c 100 -s 1500 -ni eth0 -w dump100.pcap

