### 1) Работа c HTTP через телнет. Подключитесь утилитой телнет к сайту stackoverflow.com telnet stackoverflow.com 80. Отправьте HTTP запрос. В ответе укажите полученный HTTP код, что он означает?

Код ниже. Код ответа 301 (редирект на https://stackoverflow.com/questions)

	HTTP/1.1 301 Moved Permanently
	cache-control: no-cache, no-store, must-revalidate
	location: https://stackoverflow.com/questions
	x-request-guid: 8801e45c-1119-4faf-97fe-828f36f60cc8
	feature-policy: microphone 'none'; speaker 'none'
	content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com
	Accept-Ranges: bytes
	Date: Tue, 30 Nov 2021 10:52:43 GMT
	Via: 1.1 varnish
	Connection: close
	X -Served-By: cache-hel1410020-HEL
	X-Cache: MISS
	X-Cache-Hits: 0
	X-Timer: S1638269563.096146,VS0,VE109
	Vary: Fastly-SSL
	X-DNS-Prefetch-Control: off
	Set-Cookie: prov=114f3af5-ee62-7ac0-6584-03671a36c69d; domain=.stackoverflow.com; expires=Fri, 01-Jan-2055 00:00:00 GMT; path=/; HttpOnly

### 2) Повторите задание 1 в браузере, используя консоль разработчика F12. Откройте вкладку Network. Отправьте запрос http://stackoverflow.com. Найдите первый ответ HTTP сервера, откройте вкладку Headers. Укажите в ответе полученный HTTP код. Проверьте время загрузки страницы, какой запрос обрабатывался дольше всего? Приложите скриншот консоли браузера в ответ.

Скриншот во вложении. HTTP код ниже по тексту. Время загрузки страницы 1.88с, самый долгий запрос это выполнение becon.js (168мс).

	Request URL: https://stackoverflow.com/
	Request Method: GET
	Status Code: 200 
	Remote Address: 151.101.129.69:443
	Referrer Policy: strict-origin-when-cross-origin
	accept-ranges: bytes
	cache-control: private
	content-encoding: gzip
	content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com
	content-type: text/html; charset=utf-8
	date: Tue, 30 Nov 2021 10:55:53 GMT
	feature-policy: microphone 'none'; speaker 'none'
	strict-transport-security: max-age=15552000
	vary: Accept-Encoding,Fastly-SSL
	via: 1.1 varnish
	x-cache: MISS
	x-cache-hits: 0
	x-dns-prefetch-control: off
	x-frame-options: SAMEORIGIN
	x-request-guid: e64aa939-7f2e-4853-8211-3440ba2c8aa6
	x-served-by: cache-hel1410025-HEL
	x-timer: S1638269754.872220,VS0,VE112
	:authority: stackoverflow.com
	:method: GET
	:path: /
	:scheme: https
	accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
	accept-encoding: gzip, deflate, br
	accept-language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7
	cache-control: max-age=0
	cookie: prov=b9d80ab7-f8be-c939-ac35-5c3d8e2ba62e; _ga=GA1.2.1317116518.1637429121; OptanonAlertBoxClosed=2021-11-20T17:25:35.803Z;  OptanonConsent=isIABGlobal=false&datestamp=Sun+Nov+21+2021+00%3A25%3A35+GMT%2B0700+(%D0%9D%D0%BE%D0%B2%D0%BE%D1%81%D0%B8%D0%B1%D0%B8%D1%80%D1%81%D0%BA%2C+%D1%81%D1%82%D0%B0%D0%BD%D0%B4%D0%B0%D1%80%D1%82%D0%BD%D0%BE%D0%B5+%D0%B2%D1%80%D0%B5%D0%BC%D1%8F)&version=6.10.0&hosts=&landingPath=NotLandingPage&groups=C0003%3A1%2CC0004%3A1%2CC0002%3A1%2CC0001%3A1; mfnes=0cffCAEQARoLCPyI+rrtqpk6EAUyCDRkODVhNDg0; __gads=ID=a488f218357bb874:T=1638126050:S=ALNI_Ma5BTz7AfXqCT2ViI1-iBwPvwI_HQ; _gid=GA1.2.969351088.1638269707; _gat=1
	sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"
	sec-ch-ua-mobile: ?0
	sec-ch-ua-platform: "Windows"
	sec-fetch-dest: document
	sec-fetch-mode: navigate
	sec-fetch-site: none
	sec-fetch-user: ?1
	upgrade-insecure-requests: 1
	user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36

### 3) Какой IP адрес у вас в интернете?
IP (v6 адрес) адрес в сети Интернет 2a02:2698:5000:8234:d027:4528:2340:e1c2

### 4)Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой whois
JSC "ER-Telecom Holding", AS43478

### 5)Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой traceroute
Проходит через AS34533/AS43478/AS41843 (JSC "ER-Telecom") и AS15169 (Google LLC)

	vagrant@vagrant:~$ sudo traceroute -I -An 8.8.8.8
	traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
	1  10.0.2.2 [*]  0.330 ms  0.313 ms  0.303 ms
	2  192.168.8.1 [*]  6.188 ms  9.023 ms  11.219 ms
	3  10.85.255.126 [*]  14.244 ms  16.758 ms  19.230 ms
	4  109.194.88.18 [AS34533/AS43478/AS41843]  22.245 ms  24.015 ms  27.388 ms
	5  72.14.215.165 [AS15169]  48.597 ms  50.645 ms  54.545 ms
	6  72.14.215.166 [AS15169]  57.018 ms  54.189 ms  56.322 ms
	7  142.251.53.67 [AS15169]  46.787 ms  47.150 ms  49.658 ms
	8  108.170.250.83 [AS15169]  57.069 ms  58.917 ms  60.709 ms
	9  * * *
	10  172.253.66.110 [AS15169]  65.027 ms  68.927 ms  70.982 ms
	11  142.250.210.47 [AS15169]  73.314 ms  76.080 ms  60.934 ms
	12  * * *
	13  * * *
	14  * * *
	15  * * *
	16  * * *
	17  * * *
	18  * * *
	19  * * *
	20  8.8.8.8 [AS15169]  55.900 ms *



### 6Повторите задание 5 в утилите mtr. На каком участке наибольшая задержка - delay?
Задержка максимальная на участке между 4м и 5м хопом. 

	vagrant@vagrant:~$ mtr -c 30 -r -n 8.8.8.8
	Start: 2021-11-30T11:36:14+0000
	HOST: vagrant                     Loss%   Snt   Last   Avg  Best  Wrst StDev
	1.|-- 10.0.2.2                   0.0%    30    0.8   1.1   0.3   5.0   0.8
	2.|-- 192.168.8.1                0.0%    30    6.4   7.2   5.4  12.5   1.4
	3.|-- 10.85.255.126              0.0%    30    6.5   8.2   5.6  15.7   2.0
	4.|-- 109.194.88.18              0.0%    30    8.0   9.2   6.1  27.6   4.1
	5.|-- 72.14.215.165              0.0%    30   48.6  47.7  44.0  58.3   2.8
	6.|-- 72.14.215.166              0.0%    30   49.6  50.7  48.4  74.2   4.6
	7.|-- 142.251.53.67              0.0%    30   49.6  47.5  44.3  49.6   1.2
	8.|-- 108.170.250.83            43.3%    30   72.8  68.1  59.3  95.3  10.2
	9.|-- 142.251.71.194            66.7%    30   60.7  65.5  59.1  82.9   8.7
	10.|-- 172.253.66.110             0.0%    30   61.4  62.4  58.7  97.2   6.7
	11.|-- 142.250.210.47             0.0%    30   64.0  63.1  60.1  99.5   7.0
	12.|-- ???                       100.0    30    0.0   0.0   0.0   0.0   0.0
	13.|-- ???                       100.0    30    0.0   0.0   0.0   0.0   0.0
	14.|-- ???                       100.0    30    0.0   0.0   0.0   0.0   0.0
	15.|-- ???                       100.0    30    0.0   0.0   0.0   0.0   0.0
	16.|-- ???                       100.0    30    0.0   0.0   0.0   0.0   0.0
	17.|-- ???                       100.0    30    0.0   0.0   0.0   0.0   0.0
	18.|-- 8.8.8.8                   76.7%    30   58.2  63.8  58.2  79.2   7.3

### 7)Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? воспользуйтесь утилитой dig
NS запись для dns.google:
 
	dns.google.             10800   IN      NS      ns1.zdns.google.
	dns.google.             10800   IN      NS      ns4.zdns.google.
	dns.google.             10800   IN      NS      ns2.zdns.google.
	dns.google.             10800   IN      NS      ns3.zdns.google.

А запись dns.google:

	dns.google.             326     IN      A       8.8.8.8
	dns.google.             326     IN      A       8.8.4.4

### 8)Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой dig
Домен привязан dns.google к 8.8.8.8 b 8.8.4.4. PTR запись ниже. 

	;; ANSWER SECTION:
	8.8.8.8.in-addr.arpa.   73372   IN      PTR     dns.google.

	;; ANSWER SECTION:
	4.4.8.8.in-addr.arpa.   3901    IN      PTR     dns.google.