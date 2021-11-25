### 1) Какого типа команда cd?
Отдельного файла для "сd" нет. Похоже "cd" встроена непосредственно в шелл. 

	vagrant@vagrant:~$ whereis cd
	cd:
	vagrant@vagrant:~$ type -a cd
	cd is a shell builtin

### 2) Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l?
Альтерантива grep c ключом -c, т.е. "grep <some_string> <some_file> -с"

### 3) Какой процесс с PID 1 является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?
Нам поможет команда "ps axjf". Это процесс systemd с PID 1
Он является предком таких процеессов как: sshd, cron, rsyslogd и т.д.

### 4) Как будет выглядеть команда, которая перенаправит вывод stderr ls на другую сессию терминала?

	vagrant@vagrant:~$ ls 2> /dev/pts/1

### 5) Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? 
Да, пример ниже:

	vagrant@vagrant:~$ sort < input.txt > output.txt
	vagrant@vagrant:~$ cat input.txt
	5
	4
	3
	1
	8
	3
	vagrant@vagrant:~$ cat output.txt
	1
	3
	3
	4
	5
	8
	
### 6) Получится ли вывести находясь в графическом режиме данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?
Да, вывести получилось на tty1 из pts/0 (см. ниже).

	vagrant@vagrant:/dev$ w
	 18:42:14 up  4:48,  3 users,  load average: 0.00, 0.00, 0.00
	USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
	vagrant  tty1     -                18:41   14.00s  0.04s  0.01s -bash
	vagrant  pts/0    10.0.2.2         18:36    6.00s  0.08s  0.00s w
	vagrant  pts/1    10.0.2.2         18:38    3:18   0.00s  0.00s -bash
	vagrant@vagrant:/dev$ echo "TEST" > /dev/tty1
	vagrant@vagrant:/dev$ 

### 7) Выполните команду bash 5>&1. К чему она приведет? Что будет, если вы выполните echo netology > /proc/$$/fd/5? Почему так происходит?

bash 5>&1 приводит к созданию файлового дескриптора 5 с редиректом на 1, т.е. на STDOUT. Именно поэтому при перенаправдении вывода в 5 выполняя команду echo netology мы видим сообщение на stdout.

### 8) Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty? Напоминаем: по умолчанию через pipe передается только stdout команды слева от | на stdin команды справа. Это можно сделать, поменяв стандартные потоки местами через промежуточный новый дескриптор, который вы научились создавать в предыдущем вопросе.

	vagrant@vagrant:~$ ls non_existent_file 3>&2 2>&1 1>&3 | cat > ls_stderr.txt
	vagrant@vagrant:~$ cat ls_stderr.txt
	ls: cannot access 'non_existent_file': No such file or directory
	vagrant@vagrant:~$

### 9) Что выведет команда cat /proc/$$/environ? Как еще можно получить аналогичный по содержанию вывод?
Выводит переменные окруения. Аналогичный вывод можно получить с помощью команды env/printenv

### 10) Используя man, опишите что доступно по адресам /proc/<PID>/cmdline, /proc/<PID>/exe.
Строка мануала man proc 199 и 247 соответсвенно.
Первый файл хранит команду, которой был вызван процесс.

	vagrant@vagrant:~$ cat /proc/647/cmdline
	/usr/sbin/cron-f
	
Второй файл хранит симлинк на файл, который был запущен.

	vagrant@vagrant:~$ sudo ls -la /proc/647/exe
	lrwxrwxrwx 1 root root 0 Nov 24 18:33 /proc/647/exe -> /usr/sbin/cron  

### 11) Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью /proc/cpuinfo
Поддержка sse4 наиболее старшая.

	vagrant@vagrant:~$ cat /proc/cpuinfo | grep sse
	flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 
	ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq monitor 
	ssse3 cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti 
	fsgsbase avx2 invpcid rdseed clflushopt md_clear flush_l1d

### 12) При открытии нового окна терминала и vagrant ssh создается новая сессия и выделяется pty. Почитайте, почему так происходит, и как изменить поведение.

При выполнении команды "ssh localhost 'tty' " не создается терминал и команда не запускается внутри терминала. Это также видно в исполнении команды ниже.

	vagrant@vagrant:~$ ssh localhost 'w'
	vagrant@localhost's password:
	 17:22:03 up 29 min,  1 users,  load average: 0.04, 0.01, 0.00
	USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
	vagrant  pts/0    10.0.2.2         16:52   11.00s  0.11s  0.01s ssh localhost w

Для того, чтобы создать терминал в ssh есть ключ -t. 

	vagrant@vagrant:~$ ssh -t localhost 'tty'
	vagrant@localhost's password:
	/dev/pts/1
	Connection to localhost closed.

### 13) Бывает, что есть необходимость переместить запущенный процесс из одной сессии в другую. Попробуйте сделать это, воспользовавшись reptyr. Например, так можно перенести в screen процесс, который вы запустили по ошибке в обычной SSH-сессии.

	vagrant@vagrant:~$ reptyr -v
	This is reptyr version 0.6.2.
	 by Nelson Elhage <nelhage@nelhage.com>
	http://github.com/nelhage/reptyr/
	vagrant@vagrant:~$ sudo su
	root@vagrant:/home/vagrant# echo 0 > /proc/sys/kernel/yama/ptrace_scope
	vagrant@vagrant:~$ top
	^Z
	[1]+  Stopped                 top
	vagrant@vagrant:~$ jobs -l
	[1]+  2428 Stopped                 top
	vagrant@vagrant:~$ ps ax | grep top
	   2428 pts/1    T      0:00 top
	   2444 pts/1    S+     0:00 grep --color=auto ping
	 vagrant@vagrant:~$ disown top
	bash: warning: deleting stopped job 1 with process group 2428
	vagrant@vagrant:~$ jobs -l
	vagrant@vagrant:~$ ps ax | grep top
	   2428 pts/1    T      0:00 top
	   2446 pts/1    S+     0:00 grep --color=auto ping
	vagrant@vagrant:~$ screen

In screen!

	vagrant@vagrant:~$ reptyr 2428

### 14) sudo echo string > /root/new_file не даст выполнить перенаправление под обычным пользователем, так как перенаправлением занимается процесс shell'а, который запущен без sudo под вашим пользователем. Для решения данной проблемы можно использовать конструкцию echo string | sudo tee /root/new_file. Узнайте что делает команда tee и почему в отличие от sudo echo команда с sudo tee будет работать.

sudo не делает перенаправление превилигированным, т.е. > выполняется от обычного пользователя. 
tee позволяет записывать в файл из stdin, и в конструкции ниже tee получит вывод из echo, повысит права и запишет в файл.

	echo string | sudo tee /root/new_file.