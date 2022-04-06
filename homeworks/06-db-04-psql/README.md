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

Создаем таблицы orders_1 и orders_2 для шардинга:

```
test_database=# CREATE TABLE orders_1 ( CHECK (price > 499)) INHERITS (orders);
CREATE TABLE
test_database=# CREATE TABLE orders_2 ( CHECK (price <= 499)) INHERITS (orders);
CREATE TABLE

test_database=# SELECT * FROM orders_1;
 id | title | price 
----+-------+-------
(0 rows)

test_database=# SELECT * FROM orders_2;
 id | title | price 
----+-------+-------
(0 rows)
```
Наполняем таблицу данными из основной таблицы и очищаем таблицу orders (не забываем поставить параметр ONLY, иначе очистятся таблицы шардинга):

```
INSERT INTO orders_1 (id, title, price) SELECT id, title, price FROM orders WHERE price > 499;
INSERT INTO orders_2 (id, title, price) SELECT id, title, price FROM orders WHERE price <= 499;
DELETE FROM ONLY orders;
```
Создаем правила для автоматического шардирования по условиям из задания (для исклюяения ручного разбиения):

```
test_database=# CREATE RULE orders_insert_to_1 AS ON INSERT TO orders WHERE (price > 499) DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);
CREATE RULE
test_database=# CREATE RULE orders_insert_to_2 AS ON INSERT TO orders WHERE (price <= 499) DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
CREATE RULE
```
Проверяем работоспособность правил (предварительно очищая таблицу orders и все ее шардинг таблицы):

```
test_database=# DELETE FROM orders;
test_database=# INSERT INTO orders (id, title, price) VALUES (1,'War and peace', 100);
test_database=# INSERT INTO orders (id, title, price) VALUES (2,'My little database', 500);
test_database=# INSERT INTO orders (id, title, price) VALUES (3,'Adventure psql time', 300);
test_database=# INSERT INTO orders (id, title, price) VALUES (4,'Server gravity falls', 300);
test_database=# INSERT INTO orders (id, title, price) VALUES (5,'Log gossips', 123);
test_database=# INSERT INTO orders (id, title, price) VALUES (6,'WAL never lies', 900);
test_database=# INSERT INTO orders (id, title, price) VALUES (7,'Me and my bash-pet', 499);
test_database=# INSERT INTO orders (id, title, price) VALUES (8,'Dbiezdmin', 501);

test_database=# SELECT * FROM  orders;
 id |        title         | price 
----+----------------------+-------
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(8 rows)

test_database=# SELECT * FROM ONLY orders;
 id | title | price 
----+-------+-------
(0 rows)

test_database=# SELECT * FROM orders_1;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# SELECT * FROM orders_2;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?


### Ответ

Выполняем backup таблиц БД test_database в файл test_database_shard.backup:
```
vagrant@server1:~$ docker exec -it 537d7d0d7684 pg_dump -U postgres -f /mnt/data1/test_database_shard.backup test_database
```

Проверяем наличие файла и вывод всей портянки в stdout:

```
vagrant@server1:~$ cat data1/test_database_shard.backup 
--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2 (Debian 14.2-1.pgdg110+1)
-- Dumped by pg_dump version 14.2 (Debian 14.2-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_1; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_1 (
    CONSTRAINT orders_1_price_check CHECK ((price > 499))
)
INHERITS (public.orders);


ALTER TABLE public.orders_1 OWNER TO postgres;

--
-- Name: orders_2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_2 (
    CONSTRAINT orders_2_price_check CHECK ((price <= 499))
)
INHERITS (public.orders);


ALTER TABLE public.orders_2 OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: orders_1 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_1 ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: orders_1 price; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_1 ALTER COLUMN price SET DEFAULT 0;


--
-- Name: orders_2 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_2 ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: orders_2 price; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_2 ALTER COLUMN price SET DEFAULT 0;


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, title, price) FROM stdin;
\.


--
-- Data for Name: orders_1; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders_1 (id, title, price) FROM stdin;
2	My little database	500
6	WAL never lies	900
8	Dbiezdmin	501
\.


--
-- Data for Name: orders_2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders_2 (id, title, price) FROM stdin;
1	War and peace	100
3	Adventure psql time	300
4	Server gravity falls	300
5	Log gossips	123
7	Me and my bash-pet	499
\.


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 8, true);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: orders orders_insert_to_1; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE orders_insert_to_1 AS
    ON INSERT TO public.orders
   WHERE (new.price > 499) DO INSTEAD  INSERT INTO public.orders_1 (id, title, price)
  VALUES (new.id, new.title, new.price);


--
-- Name: orders orders_insert_to_2; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE orders_insert_to_2 AS
    ON INSERT TO public.orders
   WHERE (new.price <= 499) DO INSTEAD  INSERT INTO public.orders_2 (id, title, price)
  VALUES (new.id, new.title, new.price);


--
-- PostgreSQL database dump complete
--
```

Для того, чтобы добавить уникальность поля title можно добавить уникальное ограничение в бекап, а именно:

```
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
+   ADD CONSTRAINT orders_unique_title UNIQUE (title);
```
