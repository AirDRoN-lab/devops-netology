1-4) Задания выполнены. Vagrant и VB установлен.

PS C:\Users\dmgol\PycharmProjects\DEVSYS\Homeworks\devops-netology\homeworks> vagrant.exe --version
Vagrant 2.2.19

5) 
По умолчанию выделен ресурс RAM 1024МБ и 2 CPU.

6) 
Для выделения ресурсов для VM в VagrantFile необходимо прописать:
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 1
  end

7) 
По ssh на ВМ зашел успешно:

PS C:\Users\dmgol\VagrantVM> vagrant ssh
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat 20 Nov 2021 06:24:16 PM UTC

  System load:  0.0               Processes:             101
  Usage of /:   2.5% of 61.31GB   Users logged in:       0
  Memory usage: 8%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Sat Nov 20 17:15:39 2021 from 10.0.2.2
vagrant@vagrant:~$

8)
Длину журнала можно задать переменной HISTSIZE, строка мануала 740
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000

Директива ignoreboth это обьединение значений опции ignorespace and ignoredups переменной HISTCONTROL.
При применении данного значения в истории не будут сохраняться команды начинающийся с пробела и совпадающие с предидущей выполненной командой.

9) 
Строка мануала  232
Фигурные скобки можно применять в командной строке bash для сокращения команд и применять для перечисления значения аргументов (см п.10).

10) 
Создать 100000 файлов можно используя команду touch {1..100000}.txt
300000 фалов создать не получается, вывод -bash: /usr/bin/touch: Argument list too long
При выполнении команды значения фигурных скобок преобразуеся в последовательный набор аргументов, который ограничен системой (см. ниже).	

vagrant@vagrant:~/test$ xargs --show-limits
POSIX upper limit on argument length (this system): 2092925

11)
В man bash строка 1629 описан ключ -d в конструкции выражения [[.
[[ -d /tmp ]] вернет единицу, если /tmp существует и является директорией.

12) 
Перечень команд для достижения целевого результата данного пункта домашнего задания:
vagrant@vagrant:~/test$ mkdir /tmp/newdir
vagrant@vagrant:~/test$ sudo ln /usr/bin/bash /tmp/newdir
vagrant@vagrant:~/test$ export PATH="/tmp/newdir:$PATH"
vagrant@vagrant:~/test$ echo $PATH
/tmp/newdir:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
vagrant@vagrant:~/test$ type -a bash
bash is /tmp/newdir/bash
bash is /usr/bin/bash
bash is /bin/bash

13)
строка "man at" 19 и 26. 
Разница заключается в том, что at выполняется в запланированное время, а batch при достижении утилизации системы ниже 1.5 (дефолт).
