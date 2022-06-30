# Домашнее задание к занятию "08.03 Использование Yandex Cloud"

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.

Дописано два Play: Install NGINX и Install LIGHTHOUSE. Первый для установки NGINX, второй для установки Lighthouse.

```ansible
- name: Install NGINX
  hosts: lighthouse-01
  tags: nginx
  tasks:
    - name: NGINX INSTALL by apt
      become: true
      ansible.builtin.apt:
        update_cache: yes
        package: "{{ item }}"
      with_items:
        - nginx
- name: Install LIGHTHOUSE
  hosts: lighthouse-01
  tags: lighthouse
  handlers:
    - name: reload-nginx
      become: true
      ansible.builtin.systemd:
        name: nginx
        state: reloaded
  pre_tasks: 
    - name: Install GIT
      become: true
      ansible.builtin.apt:
        update_cache: yes
        package: "{{ item }}"
      with_items:
        - git
  tasks:
    - name: Git clone LIGHTHOUSE
      become: true
      ansible.builtin.git: 
        repo: '{{ lighthouse_repo }}'
        dest: '{{ lighthouse_dir }}'
    - name: Reconfigure NGINX
      become: true
      ansible.builtin.lineinfile:
        dest: '/etc/nginx/sites-available/default'
        regexp: 'root /var/www/html;'
        line: 'root /var/www/lighthouse;'
      notify: reload-nginx
```

2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.

Да, данные модули использованы.

3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.

В качестве вебсервера установлен nginx. Скриншот окна Lighthouse в веб браузере по [ссылке](./Screen_Lighthouse.JPG)

4. Приготовьте свой собственный inventory файл `prod.yml`.

В inventory файл вошли три VM. IP адреса VM передаются через --extravars. Ansible playbook запускается с помощью bash скрипта `./Start.sh play`

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Запущено и исправлено. Основная ошибка это `[201] Trailing whitespace`.

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

Выполнение прервалось на клонировании репозитория, т.к. git не был установлен (т.к. флаг --check)

```ansible
vagrant@server1:~/ansible2-netology$ ./start.sh check
--- Using IP adresses ...
"51.250.71.81"
"51.250.64.45"
"51.250.95.242"

PLAY [Install NGINX] *********************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [NGINX INSTALL by apt] **************************************************************************************************************************************************************************************
changed: [lighthouse-01] => (item=nginx)

PLAY [Install LIGHTHOUSE] ****************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [Install GIT] ***********************************************************************************************************************************************************************************************
changed: [lighthouse-01] => (item=git)

TASK [Git clone LIGHTHOUSE] **************************************************************************************************************************************************************************************
fatal: [lighthouse-01]: FAILED! => {"changed": false, "msg": "Failed to find required executable \"git\" in paths: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"}

PLAY RECAP *******************************************************************************************************************************************************************************************************
lighthouse-01              : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```ansible
vagrant@server1:~/ansible2-netology$ ./start.sh play
--- Using IP adresses ...
"51.250.71.81"
"51.250.64.45"
"51.250.95.242"

PLAY [Install NGINX] *********************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [NGINX INSTALL by apt] **************************************************************************************************************************************************************************************
ok: [lighthouse-01] => (item=nginx)

PLAY [Install LIGHTHOUSE] ****************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [Install GIT] ***********************************************************************************************************************************************************************************************
ok: [lighthouse-01] => (item=git)

TASK [Git clone LIGHTHOUSE] **************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [Reconfigure NGINX] *****************************************************************************************************************************************************************************************
ok: [lighthouse-01]

PLAY [Install CLICKHOUSE] ****************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ************************************************************************************************************************************************************************************
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.deb", "elapsed": 0, "gid": 1001, "group": "vagrant", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "vagrant", "response": "HTTP Error 404: Not Found", "size": 246378832, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/deb/pool/stable/clickhouse-common-static_22.3.3.44_all.deb"}
changed: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)

TASK [Get clickhouse distrib (rescue)] ***************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] *******************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-common-static)
Selecting previously unselected package clickhouse-client.
(Reading database ... 65558 files and directories currently installed.)
Preparing to unpack clickhouse-client-22.3.3.44.deb ...
Unpacking clickhouse-client (22.3.3.44) ...
Setting up clickhouse-client (22.3.3.44) ...
changed: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)

TASK [Reconfig Clickhouse. Listen 0/0] ***************************************************************************************************************************************************************************
--- before: /etc/clickhouse-server/config.xml
+++ after: /home/vagrant/.ansible/tmp/ansible-local-170443q_ywz2f/tmpkg9asvs3/config.j2
@@ -183,10 +183,8 @@
     <!-- <listen_host>0.0.0.0</listen_host> -->
 
     <!-- Default values - try listen localhost on IPv4 and IPv6. -->
-    <!--
-    <listen_host>::1</listen_host>
-    <listen_host>127.0.0.1</listen_host>
-    -->
+    
+    <listen_host>0.0.0.0</listen_host>
 
     <!-- Don't exit if IPv6 or IPv4 networks are unavailable while trying to listen. -->
     <!-- <listen_try>0</listen_try> -->
@@ -1294,4 +1292,4 @@
         </tables>
     </rocksdb>
     -->
-</clickhouse>
+</clickhouse>
\ No newline at end of file

changed: [clickhouse-01]

TASK [Flush handlers if possible] ********************************************************************************************************************************************************************************

RUNNING HANDLER [Start clickhouse service] ***********************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Create database] *******************************************************************************************************************************************************************************************
changed: [clickhouse-01]

PLAY [Install VECTOR] ********************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Get Vector distrib by get_url] *****************************************************************************************************************************************************************************
changed: [vector-01]

TASK [Mkdir for Vector by file] **********************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0775",
+    "mode": "0755",
     "path": "vector",
-    "state": "absent"
+    "state": "directory"
 }

changed: [vector-01]

TASK [Install UnZIP by apt] **************************************************************************************************************************************************************************************
Suggested packages:
  zip
The following NEW packages will be installed:
  unzip
0 upgraded, 1 newly installed, 0 to remove and 4 not upgraded.
changed: [vector-01] => (item=unzip)

TASK [UnZIP Vector] **********************************************************************************************************************************************************************************************
changed: [vector-01]

TASK [Add EnvPATH to profile] ************************************************************************************************************************************************************************************
--- before: /home/vagrant/.profile (content)
+++ after: /home/vagrant/.profile (content)
@@ -25,3 +25,4 @@
 if [ -d "$HOME/.local/bin" ] ; then
     PATH="$HOME/.local/bin:$PATH"
 fi
+export PATH="$HOME/vector/bin:$PATH"

changed: [vector-01]

TASK [Commit EnvPATH] ********************************************************************************************************************************************************************************************
changed: [vector-01]

TASK [CHECK EnvPATH and other VAR (for check only)] **************************************************************************************************************************************************************
ok: [vector-01] => {
    "msg": "PATH variables /home/vagrant/vector/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin, HOME directory /home/vagrant, VM IP 51.250.64.45"
}

TASK [ADD group vector for Vector] *******************************************************************************************************************************************************************************
changed: [vector-01]

TASK [ADD user vector for Vector] ********************************************************************************************************************************************************************************
changed: [vector-01]

TASK [Change vector.service file for systemd] ********************************************************************************************************************************************************************
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

changed: [vector-01]

TASK [Change vector.service file for systemd. Disable PreStart] **************************************************************************************************************************************************
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

changed: [vector-01]

TASK [Copy vector.service to system dir] *************************************************************************************************************************************************************************
changed: [vector-01]

TASK [Starting vector by systemd] ********************************************************************************************************************************************************************************
changed: [vector-01]

PLAY RECAP *******************************************************************************************************************************************************************************************************
clickhouse-01              : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
lighthouse-01              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

--- All ok. Check the service! 
```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

Повторный запуск проблем не выявил. Да, выполняется повторная распаковка vector и изменение конфигурации в файлах.
Ничего страшного в этом нет.

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

Файл подгтовлен. Playbook состоит из четырех  Play: Install NGINX, Install LightHouse, Install ClickHouse и Install VECTOR.
Сформирован [bash](./start.sh) скрипт запуска для ускорения процессов. [Bash](./start.sh) скрипт может запускаться:

```bash
./start.sh apply # выполняет terraform init и terrfaorm apply
./start.sh play # выполняет запуск playbook c необходимыми опциями (extravars, diff, путь до инвентори и плейбука)
./start.sh showip # выполняет terraform output с нужными параметрами
./start.sh check # выполняет запуск playbook с опцией --check
./start.sh destroy # выполняет terraform destroy
```

Описание тасков ansible:

```ansible
Таски Install Nginx
- name: NGINX INSTALL by apt # установка NGINX из apt

Таски Install Lighthouse
- name: reload-nginx # handler на релоад nginx через systemd
- name: Install GIT # pre-task на установку git через apt
- name: Git clone LIGHTHOUSE # клонирование репозитория Lighthouse
- name: Reconfigure NGINX # смена директории расположения файла index.html. Меняем на место установки lighhouse. Делаем notify.

Таски Install ClickHouse
- name: Get clickhouse distrib  # скачивает deb пакет указанной версии
- name: Get clickhouse distrib (rescue)  # скачивает deb пакет указанной версии (повтор для common static, т.к. не попадает под шаблон верхней таски)
- name: Install clickhouse packages # вектор устанавливает через менеджер apt
- name: Reconfig Clickhouse. Listen 0/0 # копирует конфиг файл из локальной директории. В конфигурации добавлен ListenInterface 0.0.0.0, в противном случае слушает только на 127.0.0.1.
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

```ansible
{{ ansible_facts["env"]["HOME"] }} # домашняя директория пользователя под которым выполняются все манипуляцуии на удаленной VM
{{ vector_version }} # версия vactor из group_vars
{{ clickhouse_version }} # версия clickhouse из group_vars
{{ vmip1 }}  # IP адрес удаленной VM Lighthouse, передается через extra_vars при запуске (см. п.1)
{{ vmip2 }}  # IP адрес удаленной VM Clickhouse, передается через extra_vars при запуске (см. п.1)
{{ vmip3 }}  # IP адрес удаленной VM Vector, передается через extra_vars при запуске (см. п.1)
{{ clickhouse_listen_host }}
{{ lighthouse_repo }} # репозиторий Lighthouse
{{ lighthouse_dir }} # директория установки Lighthouse
```

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

Выполнено! [Ссылка на скрин](./Screen_Lighthouse.JPG) веб ббраузера с открытым Lighthouse и выбранной базой данных logs.