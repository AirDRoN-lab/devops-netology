### 1)
Отдельного файла для "сd" нет. Похоже "cd" встроена непосредственно в шелл. 

	vagrant@vagrant:~$ whereis cd
	cd:
	vagrant@vagrant:~$ type -a cd
	cd is a shell builtin

### 2) Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l?
Альтерантива grep c ключом -c, т.е. "grep <some_string> <some_file> -с"

### 3)
