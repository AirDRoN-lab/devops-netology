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

