
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

	Ansible популярен за счет простоты использования в сравнении с другими системами управения конфигурацииями. Кроме этого, система написана на языке Python, что позволяет легко дописать требуемый функционал.  
	Метод pull наиболее безопасен за счет того, что ни у одного внешнего клиента нет доступа к правам администратора кластера. 
	
## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

### Ответ:

Vagrant + Vbox:
```
PS C:\Users\dmgol\PycharmProjects\DEVSYS\devops-netology\homeworks> vagrant --version
Vagrant 2.2.19

PS C:\Program Files\Oracle\VirtualBox> .\VBoxHeadless.exe --version
Oracle VM VirtualBox Headless Interface 6.1.28
```

Ansible:
```
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

```
docker ps
```