# Домашнее задание к занятию "08.04 Создание собственных modules"

## Подготовка к выполнению
1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
3. Зайдите в директорию ansible: `cd ansible`
4. Создайте виртуальное окружение: `python3 -m venv venv`
5. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
6. Установите зависимости `pip install -r requirements.txt`
7. Запустить настройку окружения `. hacking/env-setup`
8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup`

## Основная часть

Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook. Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.

1. В виртуальном окружении создать новый `my_own_module.py` файл
2. Наполнить его содержимым из [статьи](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module).

3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.
4. Проверьте module на исполняемость локально.
5. Напишите single task playbook и используйте module в нём.
6. Проверьте через playbook на идемпотентность.
7. Выйдите из виртуального окружения.
8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.yandex_cloud_elk`
9. В данную collection перенесите свой module в соответствующую директорию.
10. Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module
11. Создайте playbook для использования этой role.
12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.
13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.
14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.
15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`
16. Запустите playbook, убедитесь, что он работает.
17. В ответ необходимо прислать ссылку на репозиторий с collection

### Ответы

Создан файл модуля  https://github.com/AirDRoN-lab/airdron.operwfile/blob/main/plugins/modules/wfile.py

Тестирование модуля выполнялось:

1) Через hacking/test-module:
```
(venv) vagrant@server2:~/REPO/ansible$ hacking/test-module -m library/mod_test.py -a 'path=/home/vagrant/punpun.txt content=HALLO'
* including generated source, if any, saving to: /home/vagrant/.ansible_module_generated
* ansiballz module detected; extracted module source to: /home/vagrant/debug_dir
***********************************
RAW OUTPUT

{"changed": true, "original_message": "/home/vagrant/punpun.txt", "message": "Fucking started?", "invocation": {"module_args": {"path": "/home/vagrant/punpun.txt", "content": "HALLO"}}}


***********************************
PARSED OUTPUT
{
    "changed": true,
    "invocation": {
        "module_args": {
            "content": "HALLO",
            "path": "/home/vagrant/punpun.txt"
        }
    },
    "message": "Fucking started?",
    "original_message": "/home/vagrant/punpun.txt"
}
```
2) Через ansible playbook:
```
(venv) vagrant@server2:~/REPO/ansible$ ansible-playbook ./testmod.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [TEST the module] ***********************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [localhost]

TASK [RUN the module] ************************************************************************************************************************
changed: [localhost]

TASK [PRINT test output] *********************************************************************************************************************
ok: [localhost] => {
    "msg": {
        "changed": true,
        "failed": false,
        "message": "NETU FILE, nu pishem ept",
        "original_message": "/home/vagrant/punpun4.txt"
    }
}

PLAY RECAP ***********************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

(venv) vagrant@server2:~/REPO/ansible$ ansible-playbook ./testmod.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [TEST the module] ***********************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [localhost]

TASK [RUN the module] ************************************************************************************************************************
ok: [localhost]

TASK [PRINT test output] *********************************************************************************************************************
ok: [localhost] => {
    "msg": {
        "changed": false,
        "failed": false,
        "message": "EST FILE",
        "original_message": "/home/vagrant/punpun4.txt"
    }
}

PLAY RECAP ***********************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

(venv) vagrant@server2:~/REPO/ansible$ cat /home/vagrant/punpun4.txt
HALLOU my FRIEND4
```

Создаем коллекцию и роль в отдельной директории:
```
vagrant@server2:~/REPO$ ansible-galaxy collection init airdron.operwfile
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
- Collection airdron.operwfile was created successfully

vagrant@server2:~/REPO/airdron/operwfile/roles$ ansible-galaxy role init operwfile
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
- Role operwfile was created successfully
```

Формируем минимальную документацию на коллецию, роль и модуль, включаю документацию внутри кода модуля. Переносим модуль в новую директорию, создаем роль, переносим переменные в defaults, а также создаем тестовый playbook:

```
- name: TEST the module
  hosts: localhost
  vars:
    path: '/home/vagrant/testfile_for_module.txt'
  collections:
    - airdron.operwfile
  roles:
    - operwfile
```

Создаем архивный файл коллекции через ansible-galaxy:
```
vagrant@server2:~/REPO/airdron/operwfile$ ansible-galaxy collection build
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
Created collection for airdron.operwfile at /home/vagrant/REPO/airdron/operwfile/airdron-operwfile-1.0.1.tar.gz
```

В итоге структура репозитория: https://github.com/AirDRoN-lab/airdron.operwfile

Для тестирования переносим архивный файл коллекции в другую директорию, распаковываем:

```
vagrant@server2:~/TEST$ ansible-galaxy install airdron-operwfile-1.0.0.tar.gz
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
Starting galaxy role install process
- airdron-operwfile-1.0.0.tar.gz is already installed, skipping.
```

Запускаем Playbook и запускаем повторно для тестирования идемпотентности:

```
vagrant@server2:~/TEST$ ansible-playbook site.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [TEST the module] ***********************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [localhost]

TASK [operwfile : Create a FILE] *************************************************************************************************************
changed: [localhost]

PLAY RECAP ***********************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

vagrant@server2:~/TEST$ cat ~/test.txt
HALLLLLLLLLLLLO
vagrant@server2:~/TEST$ ansible-playbook site.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [TEST the module] ***********************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [localhost]

TASK [operwfile : Create a FILE] *************************************************************************************************************
ok: [localhost]

PLAY RECAP ***********************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

Список коллеций и ролей:

```
vagrant@server2:~/TEST$ ansible-galaxy collection list
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.

# /home/vagrant/.ansible/collections/ansible_collections
Collection        Version
----------------- -------
airdron.operwfile 1.0.0

# /usr/lib/python3/dist-packages/ansible_collections
Collection                Version
------------------------- -------
amazon.aws                1.4.0
ansible.netcommon         1.5.0
...
vyos.vyos                 1.1.1
wti.remote                1.0.1

vagrant@server2:~/TEST$ ansible-galaxy role list
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible
engine, or trying out features under development. This is a rapidly changing source of code and can become unstable at any point.
# /home/vagrant/.ansible/roles
- airdron-operwfile-1.0.0.tar.gz, (unknown version)
```

Коллеция выложена в репозиторий с тегом 1.0.1: https://github.com/AirDRoN-lab/airdron.operwfile
В том числе продублирована в данном репозитории ДЗ.

## Необязательная часть

1. Реализуйте свой собственный модуль для создания хостов в Yandex Cloud.
2. Модуль может (и должен) иметь зависимость от `yc`, основной функционал: создание ВМ с нужным сайзингом на основе нужной ОС. Дополнительные модули по созданию кластеров Clickhouse, MySQL и прочего реализовывать не надо, достаточно простейшего создания ВМ.
3. Модуль может формировать динамическое inventory, но данная часть не является обязательной, достаточно, чтобы он делал хосты с указанной спецификацией в YAML.
4. Протестируйте модуль на идемпотентность, исполнимость. При успехе - добавьте данный модуль в свою коллекцию.
5. Измените playbook так, чтобы он умел создавать инфраструктуру под inventory, а после устанавливал весь ваш стек ELK на нужные хосты и настраивал его.
6. В итоге, ваша коллекция обязательно должна содержать: elastic-role, kibana-role, filebeat-role, два модуля: my_own_module и модуль управления Yandex Cloud хостами и playbook, который демонстрирует создание ELK-стека.

### Ответ

Будет выполнена после сдачи хвостов по ДЗ
