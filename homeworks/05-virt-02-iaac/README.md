# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
- Какой из принципов IaaC является основополагающим?

### Ответ:

IaaC Предоставляет возможность значительно ускорить процесс производства, тестирования и вывода продукта на рынок. Ускорение достигается за счет полной автоматизации процесса развертывания инфраструктры, унификации конфигурации (отсутсвует дрейф конфига).
Основополагающий принцип IaaС - это идемпотентность, т.е. абсолютная идентичность создаваемых ВМ по поттерну. 

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

### Ответ:

Ansible популярен за счет простоты использования в сравнении с другими системами управения конфигурацииями. Кроме этого, система написана на языке Python, что позволяет легко описатьтребуемый функционал.  
Метод pull наиболее безопасен за счет того, что ни у одного внешнего клиента нет доступа к правам администратора кластера. 
	
## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

### Ответ:

Vagrant и VirtualBox настроены на локальной машине Win10. В свою очередь Ansible был установленв в WSL на локальной машине, т.к. поверх Win10 штатно не устанавливается. 

Vagrant + Vbox:
```
PS C:\Users\dmgol\PycharmProjects\DEVSYS\devops-netology\homeworks> vagrant --version
Vagrant 2.2.19

PS C:\Program Files\Oracle\VirtualBox> .\VBoxHeadless.exe --version
Oracle VM VirtualBox Headless Interface 6.1.28
```

Ansible:
```bash
dgolodnikov@DESKTOP-V4JG0DR:~$ ansible --version
ansible [core 2.12.2]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/dgolodnikov/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/dgolodnikov/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/dgolodnikov/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True

```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды


### Ответ:

Vagrant и VirtualBox настроены на локальной машине Win10. В свою очередь Ansible был установленв в WSL на локальной машине.
Т.к Ansible и Vagrant установлены на разных машинах, Ansible provisioning в vagrant насстроен не был. Ansible playbook запускался вручную (см. ниже).
Файл server1.netohome.yml также выложен в текущем репозитории.
	
```bash
dgolodnikov@DESKTOP-V4JG0DR:/etc/ansible$ ansible-playbook server1.netohome.yml
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect
line lengths

PLAY [nodes] ***********************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************
ok: [server1.netohome]

TASK [Checking DNS] ****************************************************************************************************************************************************
changed: [server1.netohome]

TASK [Installing tools] ************************************************************************************************************************************************
ok: [server1.netohome] => (item=git)
ok: [server1.netohome] => (item=curl)
ok: [server1.netohome] => (item=net-tools)

TASK [Installing docker] ***********************************************************************************************************************************************
changed: [server1.netohome]

TASK [Add the current user to docker group] ****************************************************************************************************************************
ok: [server1.netohome]

PLAY RECAP *************************************************************************************************************************************************************
server1.netohome           : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

```bash

vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

```