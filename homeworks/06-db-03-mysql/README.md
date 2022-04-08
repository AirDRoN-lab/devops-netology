# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.
Перейдите в управляющую консоль `mysql` внутри контейнера.
Используя команду `\h` получите список управляющих команд.
Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
Подключитесь к восстановленной БД и получите список таблиц из этой БД.
**Приведите в ответе** количество записей с `price` > 300.
В следующих заданиях мы будем продолжать работу с данным контейнером.

### Ответ:

Запускаем контейнер:
```
vagrant@server1:~$ docker run --name dockermysql -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 -d -v /backupdb mysql:8.0.28
10044f54e3a1e41ae61734579318c59b99e0619ba2cdd75e4dab61eab6d135ac

vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                                                  NAMES
10044f54e3a1   mysql:8.0.28     "docker-entrypoint.s…"   8 seconds ago   Up 3 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   dockermysql
```

Скачиваем дамп, выкладываем в директорию /backupdb. Заходим в базу для создания БД test_db:
```
vagrant@server1:~$ docker exec -it dockermysql mysql -uroot -p

mysql>  CREATE DATABASE test_db; 
Query OK, 1 row affected (0.06 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test_db            |
+--------------------+
5 rows in set (0.01 sec)

mysql>  exit
```

Для выполнения бекапа заходим в контейнер и выполняем бекап:
```
vagrant@server1:/backupdb$ docker exec -it f9ab4a5a7658 /bin/bash

root@f9ab4a5a7658:/mnt/data1# ls /mnt/data1/
test_dump.sql

root@f9ab4a5a7658:/# mysql -u root -p test_db < /mnt/data1/test_dump.sql
```

Список управляющих команд:
```
mysql> \h

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.

For server side help, type 'help contents'

```

Проверка status-а, версия MySQL:
```
mysql> \s
--------------
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)
...
Threads: 2  Questions: 53  Slow queries: 0  Opens: 152  Flush tables: 3  Open tables: 70  Queries per second avg: 0.000
--------------
```

Вход в БД test_db, проверяем развернутые из бекапа данные:
```
mysql> use test_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed

mysql> SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> SELECT * FROM orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)
```

Запрос для поиска количества записей с `price` > 300:
```
mysql> select * from orders where (price > 300);
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)

```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

### Ответ:

```
mysql> CREATE USER 'test'@'localhost'
    -> IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> WITH MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> ATTRIBUTE '{"fname": "Pretty", "lname": "James"}';
Query OK, 0 rows affected (0.09 sec)

mysql> GRANT SELECT ON test_db.* TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.03 sec)

mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test' AND HOST = 'localhost'
    -> ;
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "Pretty", "lname": "James"} |
+------+-----------+---------------------------------------+
1 row in set (0.01 sec)

```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.
Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

### Ответ:

Установоиваем профилирование и выполняем команды согласно задания:
```
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA='test_db';
+--------+
| ENGINE |
+--------+
| InnoDB |
+--------+
1 row in set (0.01 sec)

SHOW ENGINES;
mysql> SHOW ENGINES;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
9 rows in set (0.01 sec)

mysql> ALTER TABLE orders ENGINE='MyISAM';
Query OK, 5 rows affected (0.05 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE='InnoDB';
Query OK, 5 rows affected (0.05 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+--------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                |
+----------+------------+--------------------------------------------------------------------------------------+
|        1 | 0.02012825 | SHOW ENGINES                                                                         |
|        2 | 0.00095425 | select * from orders where (price > 300)                                             |
|        3 | 0.02154625 | SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA='test_db'            |
|        4 | 0.12377650 | ALTER TABLE orders ENGINE='MyISAM'                                                   |
|        5 | 0.02175475 | SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA='test_db'            |
|        6 | 0.00157150 | select * from orders where (price > 300)                                             |
|        7 | 0.14464200 | ALTER TABLE orders ENGINE='InnoDB'                                                   |
|        8 | 0.01774050 | SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA='test_db'            |
|        9 | 0.01023175 | select * from orders where (price > 300)                                             |
+----------+------------+--------------------------------------------------------------------------------------+
10 rows in set, 1 warning (0.00 sec)
```
Время на смену движка на MyISAM и на InnoDB: 0.12 и 0.14 секунд соответственно.
  |
## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

### Ответ:

Дополнение в файл my.cnf:
```
#Скорость IO важнее сохранности данных, логика сброса операция в лог на диск
innodb_flush_log_at_trx_commit = 2
#Нужна компрессия таблиц для экономии места на диске
innodb_cmp_per_index_enabled = ON
#Размер буффера с незакомиченными транзакциями 1 Мб
innodb_log_buffer_size = 1048576
#Буффер кеширования 30% от ОЗУ (принимаем RAM 128Мб)
innodb_buffer_pool_size = 40265318
#Размер файла логов операций 100 Мб
innodb_log_file_size = 104857600
```
PS: документация https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_compression_level


## Проблема 

Процесс запуска контейнера с пробросовм порта и проверке telnet на порты 3306 и 3306. Все ок:
```
vagrant@server1:/backupdb$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED      STATUS      PORTS                                                                                      NAMES
f9ab4a5a7658   mysql:8.0.28     "docker-entrypoint.s…"   2 days ago   Up 2 days   **0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 0.0.0.0:33060->33060/tcp, :::33060->33060/tcp**   dockermysql
c7de3c539b5b   postgres:12.10   "docker-entrypoint.s…"   8 days ago   Up 5 days   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp                                                  posgtres

vagrant@server1:/backupdb$ netstat -nlpt
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:33060           0.0.0.0:*               LISTEN      -                   
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      -                   
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -                   
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -                   
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN      -                   
tcp6       0      0 :::33060                :::*                    LISTEN      -                   
tcp6       0      0 :::3306                 :::*                    LISTEN      -                   
tcp6       0      0 :::22                   :::*                    LISTEN      -                   
tcp6       0      0 :::5432                 :::*                    LISTEN      -    


vagrant@server1:/backupdb$ telnet localhost 3306
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.

8.0.28_b

vagrant@server1:/backupdb$ telnet localhost 33060
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
                                                                                                                                                                       XshellXshell

```

При этом к базе не прицепляется, лезет в файл сокета:
```
vagrant@server1:/backupdb$ mysql -uroot -p
Enter password: 
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)

vagrant@server1:/backupdb$ mysql -h localhost -u root -p test_db
Enter password: 
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)

### Ответ

Вместо localhost использовать 127.0.0.1:
```
vagrant@server1:/etc/mysql/conf.d$ mysql -h 127.0.0.1 -u root test_db
```

