# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?

В директории групповых переменных т.е. group_vars/{el,deb,all}/examp.yml

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

Необходимо использовать ключ -i, т.е. ansible-playbook -i inventory/test.yml

3. Какой командой можно зашифровать файл?

ansible-vault encrypt

4. Какой командой можно расшифровать файл?

ansible-vault decrypt

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

Да, можно. Для этого можно использовать ansible-vault edit

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

Пароль можно передать ччерез файл, либо интерактивный ввод:
ansible-playbook --vault-password-file={имя файла}
ansible-playbook --ask-vault-password

7. Как называется модуль подключения к host на windows?

В документации нашел winrm (Run tasks over Microsoft's WinRM), но помойму был какой-то еще вариант =)

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

ansible-doc -t connection ssh

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

параметр remote_user

## Доп. ответы:
Скрипт автоматизации:
```sh
#!/usr/bin/env bash

run_fedora=$(docker ps -a --format "{{.Names}}" | grep fedora | wc -l)
run_centos=$(docker ps -a --format "{{.Names}}" | grep centos7 | wc -l)
run_ubuntu=$(docker ps -a --format "{{.Names}}" | grep ubuntu | wc -l)

if [ "$run_fedora" != 0 ]
then  
	
	echo "--- 'fedora' is present in docker ps -a. Trying to remove..."
        docker stop fedora && docker rm fedora
fi

if [ "$run_centos" != 0 ]
then 
        echo "--- 'centos' is present in docker ps -a. Trying to remove..."
	docker stop centos7 && docker rm centos7
fi

if [ "$run_ubuntu" != 0 ]
then 
        echo "--- 'ubuntu' is present in docker ps -a. Trying to remove..."
	docker stop ubuntu && docker rm ubuntu
fi

echo "--- Starting docker containers..."
docker run -d --name fedora pycontribs/fedora sleep 6000
docker run -d --name centos7 pycontribs/centos:7 sleep 6000
docker run -d --name ubuntu pycontribs/ubuntu sleep 6000
echo "--- Starting ansible-playbook..."
ansible-playbook -i inventory/prod.yml --vault-password-file=secret site.yml && echo "--- All ok. Stopping containers..." && docker stop fedora ubuntu centos7
```

Вывод скрипта:
```
vagrant@server1:~/ansible-netology$ ./ci_3container.sh 
--- 'fedora' is present in docker ps -a. Trying to remove...
fedora
fedora
--- 'centos' is present in docker ps -a. Trying to remove...
centos7
centos7
--- 'ubuntu' is present in docker ps -a. Trying to remove...
ubuntu
ubuntu
--- Starting docker containers...
d2fdd27b8908f1b0357a8b5b62377580b3a3aacae6307d7b4aecac11613acabd
fb0148e2abf0be26fcd01e914deeca878a568c75ce96cbb7cb1b2b2e20a2cf8d
bb477eadd317bbdc6c1d4de8b4bda1a4aebe77acc3ea346c3e17164f6b1a4800
--- Starting ansible-playbook...
[WARNING]: Found both group and host with same name: fedora

PLAY [Print os facts] *******************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************************************************
ok: [ubuntu_controlnode]
ok: [fedora]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [ubuntu_controlnode] => {
    "msg": "Ubuntu"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] ***********************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [ubuntu_controlnode] => {
    "msg": "PaSSw0rd"
}
ok: [fedora] => {
    "msg": "PaSSw0rd_for_FEDOR"
}

PLAY RECAP ******************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu_controlnode         : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

--- All ok. Stopping containers...
fedora
ubuntu
centos7
```
Шифрование строки было выполнено командой:
`ansible-vault encrypt_string --vault-password-file secret --name some_fact PaSSw0rd_for_FEDOR > group_vars/fedora/examp.yml`

Процесс установки Ansible:
```
ADD line to /etc/apt/sources.list 
deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main

$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
$ sudo apt update
$ sudo apt install ansible

vagrant@server1:~$ ansible --version
ansible [core 2.12.6]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True
```
Создание нового git окружения:
```
vagrant@server1:~/ansible-netology$ git remote add github git@github.com:AirDRoN-lab/ansible-netology.git

vagrant@server1:~/ansible-netology$ git remote -v
github	git@github.com:AirDRoN-lab/ansible-netology.git (fetch)
github	git@github.com:AirDRoN-lab/ansible-netology.git (push)
```
