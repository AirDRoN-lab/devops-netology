# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
Подключитесь к БД PostgreSQL используя `psql`.
Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

### Ответ

Создаем контейнер postgres:latest (ошибочно выбран latest, т.к. предполагалась версия 13).

```
vagrant@server1:~/data1$ docker run --name pgdb -p 5432:5432 -v /home/vagrant/data1:/mnt/data1 -e POSTGRES_PASSWORD=password -d postgres:latest
537d7d0d7684c15f3b57f6da906aee3ee3d8960c59a3b372403d487830c030c7
vagrant@server1:~/data1$ docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                       NAMES
537d7d0d7684   postgres:latest   "docker-entrypoint.s…"   4 seconds ago   Up 2 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   pgdb

vagrant@server1:~/data1$ psql -h localhost -p 5432 --username=postgres
Password for user postgres: 
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 14.2 (Debian 14.2-1.pgdg110+1))
WARNING: psql major version 12, server major version 14.
         Some psql features might not work.
Type "help" for help.
```

Команда для вывода списка БД
```
  \l[+]   [PATTERN]      list databases
```
Команда дляподключения к БД
```
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database (currently "postgres")
```
Команда для вывода списка таблиц
``` 
\d[S+]                 list tables, views, and sequences
\dt[S+] [PATTERN]      list tables
```
Команда длявывода описания содержимого таблиц
```
\d[S+]  NAME           describe table, view, sequence, or index
```
Команда для выхода из psql
```
\q                     quit psql
```

## Задача 2

Используя `psql` создайте БД `test_database`.
Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).
Восстановите бэкап БД в `test_database`.
Перейдите в управляющую консоль `psql` внутри контейнера.
Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.
**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

### Ответ

Восстанавливаем таблицу из дампа:
```
vagrant@server1:~/data1$ psql -h localhost -p 5432 --username=postgres  test_database < test_dump.sql 
Password for user postgres: 
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
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE

```
Заходим в контейнер:
```
vagrant@server1:~/data1$ docker exec -it pgdb bash
root@537d7d0d7684:/# psql
psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "root" does not exist
root@537d7d0d7684:/# psql -U postgres
psql (14.2 (Debian 14.2-1.pgdg110+1))
Type "help" for help.

```
Цепляемся к БД, проверяем:
```
postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".

test_database=# \dt+
                                      List of relations
 Schema |  Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description 
--------+--------+-------+----------+-------------+---------------+------------+-------------
 public | orders | table | postgres | permanent   | heap          | 8192 bytes | 
(1 row)

test_database=# SELECT * from orders;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
(8 rows)

```
Выполняем тест с помощью ANALYZE согласно задания:
```
test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
test_database=#

```
Выполняем поиск максимального столбца в байтах в таблице orders двумя способами (первым и похитрее):

1)
```
test_database=#  
SELECT tablename, attname ,avg_width FROM pg_stats WHERE tablename = 'orders';
 tablename | attname | avg_width 
-----------+---------+-----------
 orders    | id      |         4
 orders    | title   |        16
 orders    | price   |         4
(3 rows)

test_database=#  
SELECT tablename, attname , avg_width FROM pg_stats WHERE tablename = 'orders' ORDER BY avg_width DESC LIMIT 1;
 tablename | attname | avg_width 
-----------+---------+-----------
 orders    | title   |        16
(1 row)
```
2)
```
test_database=#                  
SELECT tablename, attname , avg_width FROM pg_stats WHERE tablename = 'orders' AND avg_width = (SELECT MAX(avg_width) from pg_stats WHERE tablename = 'orders');
 tablename | attname | avg_width 
-----------+---------+-----------
 orders    | title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
Предложите SQL-транзакцию для проведения данной операции.
Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

### Ответ

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?


### Ответ
