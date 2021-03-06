### 1) Какой системный вызов делает команда cd? В прошлом ДЗ мы выяснили, что cd не является самостоятельной программой, это shell builtin, поэтому запустить strace непосредственно на cd не получится. Тем не менее, вы можете запустить strace на /bin/bash -c 'cd /tmp'. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к cd.

Из вывода strace /bin/bash -c 'cd /tmp':

	stat("/tmp", {st_mode=S_IFDIR|S_ISVTX|0777, st_size=4096, ...}) = 0
	chdir("/tmp")
	
На мой взгляд он делает два вызова. Проверка и переход. 

### 2) Попробуйте использовать команду file на объекты разных типов на файловой системе. Используя strace выясните, где находится база данных file на основании которой она делает свои догадки.

Лоакальная пользовательская база находится в /etc/magic, но это файл не является текущей системной БД.
 
    openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3

Предположительно база находится здесь:

	openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3

Вернее здесь /usr/lib/file/magic.mgc (файл выше это симлинк).

### 3) Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Необходимо найти файловый дескриптор (есть в выводе lsof) и обнулить его. Например так:  
	echo -n "" > /proc/pid/fd/number

### 4) Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
Ресурсы ОС (CPU, RAM, IO) зомби процесс не занимает, но занимает записи в таблице процессов, которая ограничена.  


### 5) В iovisor BCC есть утилита opensnoop:
### root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
### /usr/sbin/opensnoop-bpfcc'''
### На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04. Дополнительные сведения по установке.

Файлы /var/run/utmp и /usr/local/share/dbus-1/system-services, /usr/share/dbus-1/system-services,  /lib/dbus-1/system-services (см. ниже).

	TIME(s)       PID    COMM               FD ERR FLAGS    PATH
	0.000000000   859    vminfo              6   0 02100000 /var/run/utmp
	0.000616000   595    dbus-daemon        -1   2 02304000 /usr/local/share/dbus-1/system-services
	0.000721000   595    dbus-daemon        18   0 02304000 /usr/share/dbus-1/system-services
	0.000990000   595    dbus-daemon        -1   2 02304000 /lib/dbus-1/system-services

### 6) Какой системный вызов использует uname -a? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в /proc, где можно узнать версию ядра и релиз ОС.

uname -a использует вызов uname. Из вывода strace:

	uname({sysname="Linux", nodename="vagrant", ...}) = 0
	fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0), ...}) = 0
	uname({sysname="Linux", nodename="vagrant", ...}) = 0
	uname({sysname="Linux", nodename="vagrant", ...}) = 0

Цитата:
Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.

### 7) Чем отличается последовательность команд через ; и через && в bash? Есть ли смысл использовать в bash &&, если применить set -e?

Разница в том, что ";" обеспечивает последоватеьлное выполнение комманд, тогда как && в случае, если результат предыдущего true (нулевой код завершения).
Результат выполнения двух скриптов ниже, это "+++ exited with 1 +++". Bash && на мой взгляд более универсален, так как можно использоввать непосредственно для определенных конструкциях команд и не менять поведение для всего скрипта/команды. "set -e" настройка глобальная и может быть удобна при отладке скрипта. 

	vagrant@vagrant:~$ cat test1.sh
	#!/bin/sh
	set -e
	test -d /tmp/some_dir; echo Hi
	
	vagrant@vagrant:~$ cat test2.sh
	#!/bin/sh
	test -d /tmp/some_dir && echo Hi
	
### 8) Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?

-o pipefail вовращает ноль, если какая-то команда в пайпе завершено с ненулевым кодом. 
-e выход немедленно, если комманда завершена с ненулевым кодом
-x печатать команды и аргуементы в процессе исполнения 
XXX -u Treat unset variables as an error when substituting.

Из документации:
    -e  Exit immediately if a command exits with a non-zero status.
	-u  Treat unset variables as an error when substituting.
	-x  Print commands and their arguments as they are executed.
	-o  pipefail  - the return value of a pipeline is the status of
                    the last command to exit with a non-zero status,
                    or zero if no command exited with a non-zero status


### 9) Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе. В man ps ознакомьтесь (/PROCESS STATE CODES) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

	vagrant@vagrant:~$ ps ax -o stat | sort | grep -c "^S"
	49
	vagrant@vagrant:~$ ps ax -o stat | sort | grep -c "^I"
	44

Наибольшее кол-во процессов в состоянии S (спящие процессы)
S    interruptible sleep (waiting for an event to complete)
I    Idle kernel thread		
	