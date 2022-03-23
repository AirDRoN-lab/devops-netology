# Домашнее задание к занятию "6.2. SQL"

Ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные .
Приведите получившуюся команду или docker-compose манифест.

### Ответ:

Создаем две директории для монтирования (с созданными тестовыми файлами) в контейнер postgres 
```
vagrant@server1:~$ mkdir data1
vagrant@server1:~$ mkdir data2
vagrant@server1:~$ touch data1/file1
vagrant@server1:~$ touch data2/file2

```

Подготавливаем doccker-compose файл/манифест и запускаем:
```
vagrant@server1:~$ cat dc_postgres_2vol.yml
#version: "12.10"
services:
  postgrsql:
    stdin_open: true    # docker run -i
    tty: true           # docker run -t
    image: postgres:12.10
    container_name: posgtres_12.10
    volumes:
      - data1:/mnt/data1
      - data2:/mnt/data2
    environment:
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
volumes:
  data1: {}
  data2: {}
  
vagrant@server1:~$ docker-compose -f dc_postgres_2vol.yml up -d
Creating posgtres_12.10 ... done

vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS      NAMES
8762b2fe7840   postgres:12.10   "docker-entrypoint.s…"   9 seconds ago   Up 8 seconds   5432/tcp   posgtres_12.10
```

Заходим внутрь созданного контейнера  posgtres_12.10 (8762b2fe7840):

```
docker exec -it 8762b2fe7840 bash
```
Проверям корректность монтирование 2х volume (смотрим наличие файлов):

```
root@8762b2fe7840:/mnt# ls -la data{1,2}
data1:
total 8
drwxrwxr-x 2 1000 1000 4096 Mar 20 12:33 .
drwxr-xr-x 1 root root 4096 Mar 20 16:09 ..
-rw-rw-r-- 1 1000 1000    0 Mar 20 12:33 file1

data2:
total 8
drwxrwxr-x 2 1000 1000 4096 Mar 20 12:33 .
drwxr-xr-x 1 root root 4096 Mar 20 16:09 ..
-rw-rw-r-- 1 1000 1000    0 Mar 20 12:33 file2
```
Устанавливаем клиент и цепляемся к СУБД:

```
vagrant@server1:~$ sudo apt-get install postgresql-client

vagrant@server1:~$ psql --version
psql (PostgreSQL) 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)

vagrant@server1:~$ psql -h localhost -p 5432 --username=postgres
Password for user postgres:
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=#

```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

### Ответ:

Создаем юзеров и проверяем:

```
 postgres=# CREATE USER "test-admin-user" WITH PASSWORD 'test-admin-user';
 postgres=# CREATE USER "test-simple-user" WITH PASSWORD 'test-simple-user';

 postgres=# select * from pg_user;
     usename      | usesysid | usecreatedb | usesuper | userepl | usebypassrls |  passwd  | valuntil | useconfig 
------------------+----------+-------------+----------+---------+--------------+----------+----------+-----------
 postgres         |       10 | t           | t        | t       | t            | ******** |          | 
 dmitry           |    16384 | f           | f        | f       | f            | ******** |          | 
 test-admin-user  |    16385 | f           | f        | f       | f            | ******** |          | 
 test-simple-user |    16387 | f           | f        | f       | f            | ******** |          | 
(4 rows)
```
Создаем БД test_db и проверяем:

```
postgres=# CREATE DATABASE test_db;

postgres=# select * from pg_database;
  oid  |  datname  | datdba | encoding | datcollate |  datctype  | datistemplate | datallowconn | datconnlimit | datlastsysoid | datfrozenxid | datminmxid | dattablespace |                                 datacl                                  
-------+-----------+--------+----------+------------+------------+---------------+--------------+--------------+---------------+--------------+------------+---------------+-------------------------------------------------------------------------
 13458 | postgres  |     10 |        6 | en_US.utf8 | en_US.utf8 | f             | t            |           -1 |         13457 |          480 |          1 |          1663 | 
     1 | template1 |     10 |        6 | en_US.utf8 | en_US.utf8 | t             | t            |           -1 |         13457 |          480 |          1 |          1663 | {=c/postgres,postgres=CTc/postgres}
 13457 | template0 |     10 |        6 | en_US.utf8 | en_US.utf8 | t             | f            |           -1 |         13457 |          480 |          1 |          1663 | {=c/postgres,postgres=CTc/postgres}
 16386 | test_db   |     10 |        6 | en_US.utf8 | en_US.utf8 | f             | t            |           -1 |         13457 |          480 |          1 |          1663 | {=Tc/postgres,postgres=CTc/postgres,"\"test-admin-user\"=CTc/postgres"}
(4 rows)
```
Назначем пользователю test-admin-user паравами администратора на БД test_db:

```
postgres=# GRANT ALL PRIVILEGES ON DATABASE "test_db" to "test-admin-user";
```
Заходим в БД и создаем указанные колонки (с учетом индексов и указанных типов данных). Тип serial для orders(id) по каким-то причинам создать не удалось (вывод ниже). После создание таблиц и колонок проверяем:

```
postgres=# \c  test_db

CREATE TABLE orders (
    id        integer PRIMARY KEY,
    name      varchar(40),
    cost      integer
);
 
CREATE TABLE clients (
    id 		SERIAL PRIMARY KEY,
    surname 	varchar(40),
    country 	varchar(40),
    zakaz	integer, 
    FOREIGN KEY (zakaz) REFERENCES orders(id)
);

CREATE INDEX country ON clients (country);

test_db=# \dt+
                      List of relations
 Schema |  Name   | Type  |  Owner   |  Size   | Description 
--------+---------+-------+----------+---------+-------------
 public | clients | table | postgres | 0 bytes | 
 public | orders  | table | postgres | 0 bytes | 
(2 rows)

test_db=# SELECT * FROM information_schema.tables WHERE table_schema='public';
 table_catalog | table_schema | table_name | table_type | self_referencing_column_name | reference_generation | user_defined_type_catalog | user_defined_type_schema | user_defined_type_name | is_insertable_into | is_typed | commit_action 
---------------+--------------+------------+------------+------------------------------+----------------------+---------------------------+--------------------------+------------------------+--------------------+----------+---------------
 test_db       | public       | orders     | BASE TABLE |                              |                      |                           |                          |                        | YES                | NO       | 
 test_db       | public       | clients    | BASE TABLE |                              |                      |                           |                          |                        | YES                | NO       | 
(2 rows)

test_db=# \d clients
                                    Table "public.clients"
 Column  |         Type          | Collation | Nullable |               Default               
---------+-----------------------+-----------+----------+-------------------------------------
 id      | integer               |           | not null | nextval('clients_id_seq'::regclass)
 surname | character varying(40) |           |          | 
 country | character varying(40) |           |          | 
 zakaz   | integer               |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "country" btree (country)
Foreign-key constraints:
    "clients_zakaz_fkey" FOREIGN KEY (zakaz) REFERENCES orders(id)

test_db=# \d orders
                      Table "public.orders"
 Column |         Type          | Collation | Nullable | Default 
--------+-----------------------+-----------+----------+---------
 id     | integer               |           | not null | 
 name   | character varying(40) |           |          | 
 cost   | integer               |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_zakaz_fkey" FOREIGN KEY (zakaz) REFERENCES orders(id)

test_db=# SELECT  table_name, column_name, data_type FROM information_schema.columns WHERE table_name = 'orders';

 table_name | column_name |     data_type     
------------+-------------+-------------------
 orders     | id          | integer
 orders     | name        | character varying
 orders     | cost        | integer
(3 rows)

test_db=# SELECT  table_name, column_name, data_type FROM information_schema.columns WHERE table_name = 'clients';

 table_name | column_name |     data_type     
------------+-------------+-------------------
 clients    | id          | integer
 clients    | surname     | character varying
 clients    | country     | character varying
 clients    | zakaz       | integer
(4 rows)
```
Назначем пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE на БД test_bd:

```
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE orders to "test-simple-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE clients to "test-simple-user";
```
Проверяем назначенный права:

```
test_db=# SELECT table_catalog, table_schema, table_name, privilege_type, grantee FROM information_schema.table_privileges WHERE grantee='test-simple-user';
 table_catalog | table_schema | table_name | privilege_type |     grantee      
---------------+--------------+------------+----------------+------------------
 test_db       | public       | orders     | INSERT         | test-simple-user
 test_db       | public       | orders     | SELECT         | test-simple-user
 test_db       | public       | orders     | UPDATE         | test-simple-user
 test_db       | public       | orders     | DELETE         | test-simple-user
 test_db       | public       | clients    | INSERT         | test-simple-user
 test_db       | public       | clients    | SELECT         | test-simple-user
 test_db       | public       | clients    | UPDATE         | test-simple-user
 test_db       | public       | clients    | DELETE         | test-simple-user
(8 rows)

```
PS: WTF?
```
test_db=# ALTER TABLE orders ALTER COLUMN id TYPE serial;
ERROR:  type "serial" does not exist
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

### Ответ:

Наполянем базу данными и проверяем:

```
INSERT INTO orders (id, name, cost) VALUES (1, 'Шоколад', 10);
INSERT INTO orders (id, name, cost) VALUES (2, 'Принтер', 3000);
INSERT INTO orders (id, name, cost) VALUES (3, 'Книга', 500);
INSERT INTO orders (id, name, cost) VALUES (4, 'Монитор', 7000);
INSERT INTO orders (id, name, cost) VALUES (5, 'Гитара', 4000);
INSERT INTO clients (surname, country) VALUES ('Иванов Иван Иванович', 'USA');
INSERT INTO clients (surname, country) VALUES ('Петров Петр Петрович', 'Canada');
INSERT INTO clients (surname, country) VALUES ('Иоганн Себастьян Бах', 'Japan');
INSERT INTO clients (surname, country) VALUES ('Ронни Джеймс Дио', 'Russia');
INSERT INTO clients (surname, country) VALUES ('Ritchie Blackmore', 'Russia');

test_db=# SELECT * FROM clients;
 id |       surname        | country | zakaz 
----+----------------------+---------+-------
  1 | Иванов Иван Иванович | USA     |      
  2 | Петров Петр Петрович | Canada  |      
  3 | Иоганн Себастьян Бах | Japan   |      
  4 | Ронни Джеймс Дио     | Russia  |      
  5 | Ritchie Blackmore    | Russia  |      
(5 rows)

test_db=# SELECT * FROM orders;
 id |  name   | cost 
----+---------+------
  1 | Шоколад |   10
  2 | Принтер | 3000
  3 | Книга   |  500
  4 | Монитор | 7000
  5 | Гитара  | 4000
(5 rows)
```
Подсчитываем кол-во строк, данных в таблицах clients и orders :
```
test_db=# SELECT COUNT(*) FROM clients;
 count 
-------
     5
(1 row)

test_db=# SELECT COUNT(*) FROM orders;
 count 
-------
     5
(1 row)

```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.
Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
Подсказк - используйте директиву `UPDATE`.

### Ответ:

Выполняем связку двух таблиц clients и orders. Проверяем:

```
UPDATE clients SET zakaz='3' WHERE surname='Иванов Иван Иванович'; 
UPDATE clients SET zakaz='4' WHERE surname='Петров Петр Петрович'; 
UPDATE clients SET zakaz='5' WHERE surname='Иоганн Себастьян Бах'; 

test_db=# SELECT * FROM clients WHERE zakaz IS NOT NULL;
 id |       surname        | country | zakaz 
----+----------------------+---------+-------
  1 | Иванов Иван Иванович | USA     |     3
  2 | Петров Петр Петрович | Canada  |     4
  3 | Иоганн Себастьян Бах | Japan   |     5
```
## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).
Приведите получившийся результат и объясните что значат полученные значения.

### Ответ:

Выполняем команду:

```
test_db=# EXPLAIN SELECT *  FROM clients WHERE zakaz IS NOT NULL;
                         QUERY PLAN                         
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..13.50 rows=348 width=204)
   Filter: (zakaz IS NOT NULL)
(2 rows)

test_db=# EXPLAIN SELECT *  FROM clients WHERE zakaz > 0;
                         QUERY PLAN                         
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..14.38 rows=117 width=204)
   Filter: (zakaz > 0)
(2 rows)
```

cost1 - Приблизительная стоимость запуска. Это время, которое проходит, прежде чем начнётся этап вывода данных, например для сортирующего узла это время сортировки.
cost2 - Приблизительная общая стоимость. Она вычисляется в предположении, что узел плана выполняется до конца, то есть возвращает все доступные строки. На практике родительский узел может досрочно прекратить чтение строк дочернего.
rows - Ожидаемое число строк, которое должен вывести этот узел плана. При этом так же предполагается, что узел выполняется до конца.
width - Ожидаемый средний размер строк, выводимых этим узлом плана в байтах.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
Остановите контейнер с PostgreSQL (но не удаляйте volumes).
Поднимите новый пустой контейнер с PostgreSQL.
Восстановите БД test_db в новом контейнере.
Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

### Ответ:

У postgres два инструмента выполнение бекапа, это pg_dump и pg_dumpall. Воспользуемся обоими, запускаем команду внутри контейнера:

```
vagrant@server1:~$ docker exec -it 8762b2fe7840 pg_dump -U postgres -f /mnt/data1/test_db.backup test_db
vagrant@server1:~$ docker exec -it 8762b2fe7840 pg_dumpall -U postgres -f /mnt/data1/dball.backup 

vagrant@server1:~$ ll data1/
total 20
drwxrwxr-x 2 vagrant vagrant 4096 Mar 22 06:57 ./
drwxr-xr-x 9 vagrant vagrant 4096 Mar 20 16:08 ../
-rw-r--r-- 1 root    root    6373 Mar 22 06:57 dball.backup
-rw-rw-r-- 1 vagrant vagrant    0 Mar 20 12:33 file1
-rw-r--r-- 1 root    root    3469 Mar 22 06:57 test_db.backup

```
Стопарим (docker stop) и удаляем (docker rm) контенер, чтобы создать новый:

```

vagrant@server1:~$ docker-compose -f dc_postgres_2vol.yml up -d
Creating posgtres ... done

vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                                       NAMES
3e84b56a8aae   postgres:12.10   "docker-entrypoint.s…"   8 seconds ago   Up 5 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   posgtres
vagrant@server1:~$ docker exec -it 3e84b56a8aae ls /mnt/data1 
dball.backup  file1  test_db.backup

vagrant@server1:~$ psql -h localhost -p 5432 --username=postgres -c "SELECT datname FROM pg_database;"
Password for user postgres: 
  datname  
-----------
 postgres
 template1
 template0
(3 rows)

```
pg_dump - по умолчанию не переносит ни пользователей, ни команду на создание указанной БД. Соответсвенно создаем БД и пользователей вручную (см. ниже).
Для создания базы необходимо использовать ключ -С при выполнении pg_dump. Список пользователей необходимо дампить отдельно, используя таблицу information_schema.table_privilege.

```
vagrant@server1:~$ psql -h localhost -p 5432 --username=postgres -c "CREATE DATABASE test_db;"
vagrant@server1:~$ psql -h localhost -p 5432 --username=postgres -c "CREATE USER "test-admin-user" WITH PASSWORD 'test-admin-user'; CREATE USER "test-simple-user" WITH PASSWORD 'test-simple-user'"
vagrant@server1:~$ psql -h localhost -p 5432 --username=postgres  test_db < data1/test_db.backup
```
или проще восстановить дамп из общей БД:

```
vagrant@server1:~$ psql -h localhost -p 5432 --username=postgres -f data1/dball.backup 
Password for user postgres: 
SET
SET
SET
CREATE ROLE
ALTER ROLE
psql:data1/dball.backup:16: ERROR:  role "postgres" already exists
ALTER ROLE
CREATE ROLE
ALTER ROLE
CREATE ROLE
ALTER ROLE
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
You are now connected to database "template1" as user "postgres".
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
You are now connected to database "postgres" as user "postgres".
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
CREATE DATABASE
ALTER DATABASE
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
You are now connected to database "test_db" as user "postgres".
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval 
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
GRANT
GRANT
GRANT
```
PS:
Создание pg_dump c автоматическим созданием БД и необходимых пользователей? 
Для исключения проблем с дублированием необходимо использовать ключ -c, для создания базы ключ -С. Ключ -с удаляем значения перед созданием. 
