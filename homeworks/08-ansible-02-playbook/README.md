# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению

1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.

Использована переменная `{{ yandex_vmip }}`, котороая передается в extra_vars при запуске ansible-playbook, т.е. таким образом `ansible-playbook -i inventory/prod.yml site.yml -e yandex_vmip=51.250.95.176`

```yml
---

clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: '{{ yandex_vmip }}'
```

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev)

PLAY ниже скачивает, устанавливает и запускает Vector через systemd:
```yml
- name: Install VECTOR
  hosts: clickhouse
  tasks:
    - name: Get Vector distrib by get_url
      tags: vector
      ansible.builtin.get_url:
        url: 'https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-x86_64-unknown-linux-gnu.tar.gz'
        dest: '{{ ansible_facts["env"]["HOME"] }}/vector_{{ vector_version }}_tar.gz'
    - name: Mkdir for Vector by file
      tags: vector
      ansible.builtin.file:
        path: "vector"
        state: directory
        mode: '0755'
    - name: Install UnZIP by apt
      tags: vector
      become: true
      ansible.builtin.apt:
        package: "{{ item }}"
      with_items:
        - unzip
    - name: UnZIP Vector
      tags: vector
      ansible.builtin.unarchive:
        src: '{{ ansible_facts["env"]["HOME"] }}/vector_{{ vector_version }}_tar.gz'
        dest: '{{ ansible_facts["env"]["HOME"] }}/vector'
        remote_src: yes
        extra_opts: [--strip-components=2]
    - name: Add EnvPATH to profile
      tags: vector
      ansible.builtin.lineinfile:
        dest: '{{ ansible_facts["env"]["HOME"] }}/.profile'
        regexp: ^export
        line: 'export PATH="$HOME/vector/bin:$PATH"'
    - name: Commit EnvPATH
      tags: vector
      ansible.builtin.shell:
        cmd: 'source $HOME/.profile && echo $PATH'
        executable: /bin/bash
      register: path
    - name: CHECK EnvPATH and other VAR (for check only)
      tags: vector
      ansible.builtin.debug:
        msg: 'PATH variables {{ path.stdout }}, HOME directory {{ ansible_facts["env"]["HOME"] }}, VM IP {{ yandex_vmip }}'
    - name: ADD group vector for Vector
      tags: vector
      become: true
      ansible.builtin.group:
        name: vector
        state: present
    - name: ADD user vector for Vector
      tags: vector
      become: true
      ansible.builtin.user:
        name: vector
        groups: vector
        shell: /bin/bash
    - name: Change vector.service file for systemd
      tags: vector
      ansible.builtin.lineinfile:
        dest: '{{ ansible_facts["env"]["HOME"] }}/vector/etc/systemd/vector.service'
        regexp: ^ExecStart=
        line: 'ExecStart={{ ansible_facts["env"]["HOME"] }}/vector/bin/vector --config {{ ansible_facts["env"]["HOME"] }}/vector/config/vector.toml'
    - name: Change vector.service file for systemd. Disable PreStart
      tags: vector
      ansible.builtin.lineinfile:
        dest: '{{ ansible_facts["env"]["HOME"] }}/vector/etc/systemd/vector.service'
        regexp: ^ExecStartPre=
        line: '#'
    - name: Copy vector.service to system dir
      tags: vector
      become: true
      ansible.builtin.copy:
        src: '{{ ansible_facts["env"]["HOME"] }}/vector/etc/systemd/vector.service'
        dest: /etc/systemd/system/vector.service
        mode: 0644
        owner: root
        group: root
        remote_src: yes
    - name: Starting vector by systemd
      tags: vector
      become: true
      ansible.builtin.systemd:
        name: vector
        state: started
        enabled: yes

```

3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.

Были использованы модули `get_url`, `unarchive`, `file`, `lineinfile`, apt,`user`, `group` ,`copy`,`systemd`.
`template` не использовался.

4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.

Да, это выполняется. См. п.2. Версия задается в переменной `vector_version: "0.22.0"` в group_vars.

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Да, ошибки были, но только в части лишних пробелов (пример ниже). Исправлено.

```bash
[201] Trailing whitespace
site.yml:40
      ansible.builtin.get_url:
```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

Запущен с флагом --check, все ок, вывод ниже:

```
vagrant@server1:~/ansible2-netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml -e yandex_vmip=51.250.95.176 --check

PLAY [Install ClickHouse] ************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ********************************************************************************************************************************************************************************
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.deb", "elapsed": 0, "gid": 1001, "group": "vagrant", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "vagrant", "response": "HTTP Error 404: Not Found", "size": 246378832, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/deb/pool/stable/clickhouse-common-static_22.3.3.44_all.deb"}
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)

TASK [Get clickhouse distrib (rescue)] ***********************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] ***************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-common-static)
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)

TASK [Flush handlers if possible] ****************************************************************************************************************************************************************************

TASK [Create database] ***************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

PLAY [Install VECTOR] ****************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector distrib by get_url] *************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Mkdir for Vector by file] ******************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install UnZIP by apt] **********************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=unzip)

TASK [UnZIP Vector] ******************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [Add EnvPATH to profile] ********************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Commit EnvPATH] ****************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [CHECK EnvPATH and other VAR (for check only)] **********************************************************************************************************************************************************
ok: [clickhouse-01] => {
    "msg": "PATH variables , HOME directory /home/vagrant, VM IP 51.250.95.176"
}

TASK [ADD group vector for Vector] ***************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [ADD user vector for Vector] ****************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Change vector.service file for systemd] ****************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Change vector.service file for systemd. Disable PreStart] **********************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Copy vector.service to system dir] *********************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Starting vector by systemd] ****************************************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY RECAP ***************************************************************************************************************************************************************************************************
clickhouse-01              : ok=15   changed=0    unreachable=0    failed=0    skipped=3    rescued=1    ignored=0
```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

Да, изменения произведены. Vector запущен.

```bash
vagrant@fhm7vsv12grlh8inu1bt:~/vector/etc/systemd$ systemctl status vector.service
Warning: The unit file, source configuration file or drop-ins of vector.service changed on disk. Run 'systemctl daemon-reload' to reload units.
● vector.service - Vector
     Loaded: loaded (/etc/systemd/system/vector.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-06-07 19:04:31 UTC; 10h ago
       Docs: https://vector.dev
   Main PID: 6035 (vector)
      Tasks: 4 (limit: 2316)
     Memory: 6.6M
     CGroup: /system.slice/vector.service
             └─6035 /home/vagrant/vector/bin/vector --config /home/vagrant/vector/config/vector.toml

```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

Повторный запуск проблем не выявил. Да, выполняется повторная распаковка vector и изменение конфигурации в файлах.
Ничего страшного в этом нет.

```bash

vagrant@server1:~/ansible2-netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml -e yandex_vmip=51.250.95.176 --diff

PLAY [Install ClickHouse] ************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ********************************************************************************************************************************************************************************
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.deb", "elapsed": 0, "gid": 1001, "group": "vagrant", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "vagrant", "response": "HTTP Error 404: Not Found", "size": 246378832, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/deb/pool/stable/clickhouse-common-static_22.3.3.44_all.deb"}
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)

TASK [Get clickhouse distrib (rescue)] ***********************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] ***************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-common-static)
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)

TASK [Flush handlers if possible] ****************************************************************************************************************************************************************************

TASK [Create database] ***************************************************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install VECTOR] ****************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector distrib by get_url] *************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Mkdir for Vector by file] ******************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install UnZIP by apt] **********************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=unzip)

TASK [UnZIP Vector] ******************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Add EnvPATH to profile] ********************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Commit EnvPATH] ****************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [CHECK EnvPATH and other VAR (for check only)] **********************************************************************************************************************************************************
ok: [clickhouse-01] => {
    "msg": "PATH variables /home/vagrant/vector/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin, HOME directory /home/vagrant, VM IP 51.250.95.176"
}

TASK [ADD group vector for Vector] ***************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [ADD user vector for Vector] ****************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Change vector.service file for systemd] ****************************************************************************************************************************************************************
--- before: /home/vagrant/vector/etc/systemd/vector.service (content)
+++ after: /home/vagrant/vector/etc/systemd/vector.service (content)
@@ -8,7 +8,7 @@
 User=vector
 Group=vector
 ExecStartPre=/usr/bin/vector validate
-ExecStart=/usr/bin/vector
+ExecStart=/home/vagrant/vector/bin/vector --config /home/vagrant/vector/config/vector.toml
 ExecReload=/usr/bin/vector validate
 ExecReload=/bin/kill -HUP $MAINPID
 Restart=no

changed: [clickhouse-01]

TASK [Change vector.service file for systemd. Disable PreStart] **********************************************************************************************************************************************
--- before: /home/vagrant/vector/etc/systemd/vector.service (content)
+++ after: /home/vagrant/vector/etc/systemd/vector.service (content)
@@ -7,7 +7,7 @@
 [Service]
 User=vector
 Group=vector
-ExecStartPre=/usr/bin/vector validate
+#
 ExecStart=/home/vagrant/vector/bin/vector --config /home/vagrant/vector/config/vector.toml
 ExecReload=/usr/bin/vector validate
 ExecReload=/bin/kill -HUP $MAINPID

changed: [clickhouse-01]

TASK [Copy vector.service to system dir] *********************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Starting vector by systemd] ****************************************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY RECAP ***************************************************************************************************************************************************************************************************
clickhouse-01              : ok=18   changed=4    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0

```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

Файл подгтовлен. Playbook состоит из двух Play: Install ClickHouse и Install VECTOR.

```
Таски Install ClickHouse
- name: Get clickhouse distrib  # скачивает deb пакет указанной версии
- name: Get clickhouse distrib (rescue)  # скачивает deb пакет указанной версии (повтор для common static, т.к. не попадает под шаблон верхней таски)
- name: Install clickhouse packages # вектор устанавливает через менеджер apt
- name: Flush handlers if possible # выполняет запуск через handler
- name: Create database # создает базу

Таски Install VECTOR:
- name: Get Vector distrib by get_url # скачивает архив из официального истояника
- name: Mkdir for Vector by file # создает директорию для распковки
- name: Install UnZIP by apt # устанавливает Unzip (т.к. модуль unarchive потребовал установку) с помощью модуля apt
- name: UnZIP Vector # выполняем распаковку в созданную директорию с указанными параметрами (`--strip-components=2`) из официальной документации
- name: Add EnvPATH to profile # добавляем директорию распаковки в переменные окружения (корректируем файл .profile)
- name: Commit EnvPATH # применияем переменные окружения через source
- name: CHECK EnvPATH and other VAR (for check only) # выводим переменные для визуалного контроля
- name: ADD group vector for Vector # создаем группу vector на vm
- name: ADD user vector for Vector # создаем пользователя vector на vm
- name: Change vector.service file for systemd # корректируем путь запуска в файле vector.service для переменной Start
- name: Change vector.service file for systemd. Disable PreStart # комментируем строку с переменной PreStart (т.к. не проходит vector validate и требуется указать data путь).
- name: Copy vector.service to system dir # копируем vector.service в системную директорию system.d
- name: Starting vector by systemd # запускаем vector через модуль systemd
```
Переменные используются следующие:
```
{{ ansible_facts["env"]["HOME"] }} # домашняя директория пользователя под которым выполняются все манипуляцуии на удаленной VM
{{ vector_version }} # версия vactor из group_vars
{{ clickhouse_version }} # версия clickhouse из group_vars
{{ yandex_vmip }} # IP адрес удаленной VM, передается через extra_vars при запуске (см. п.1)
```

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

Выполнено!

### Доп. вопросы

1) Как добавить/удалить символ "#" в начале строки  (найденной через regexp) в ansible при помощи модуля lineinfile (либо другого)? На данный момент удалось выполнить только replace.

2) Как передать output переменную в terraform (в частности IP адрес созданной машины) в ansible extra_vars? Необходимо для bash скрипта для автоматизации.