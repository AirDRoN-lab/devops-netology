# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
- запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
- Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.


### Ответ:

Создан репозиторий на https://hub.docker.com/ (ссылки на репозиторий ниже по тексту).<br> 
Выбран образ:
```bash
vagrant@server1:~/ansible_docker$ docker image ls
REPOSITORY                    TAG       IMAGE ID       CREATED        SIZE
nginx                         latest    c316d5a335a5   2 weeks ago    142MB
```

Сформирован Dockerфайл вида:
```
vagrant@server1:~$ cat Dockerfile
FROM nginx

RUN echo "<html>\n<head>\nHey, Netology\n</head>\n<body>\n<h1>I'm DevOps Engineer!</h1>\n</body>\n</html>" > /usr/share/nginx/html/index.html
```

Выполнен билд контейнера и его push на докерhub:
```
vagrant@server1:~$ DOCKER_BUILDKIT=0 docker build -t dgolodnikov/nginx_devtest:1.0.3 .
vagrant@server1:~$ docker image ls
REPOSITORY                    TAG       IMAGE ID       CREATED        SIZE
dgolodnikov/nginx_devtest     1.0.3     06ecd712ebf2   10 hours ago   142MB
nginx                         latest    c316d5a335a5   2 weeks ago    142MB
vagrant@server1:~$ docker push  dgolodnikov/nginx_devtest:1.0.3
```

Ссылка на репозиторий: https://hub.docker.com/repository/docker/dgolodnikov/nginx_devtest


## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

### Ответ:
Я бы разделил сервисы на различные ВМ (если позволяет бюджет), как минимум следующим образом (см. ниже). Деление сервисов функциональное и связано с полной изоляцией ресурсов между собой. 

1) Сервис - 1ВМ
- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- MongoDB, как основное хранилище данных для java-приложения;
- Шина данных на базе Apache Kafka;

2) Мониторинг, логирование - 8ВМ
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;

3) Репозитории Docker, Git, бекапы и т.п. - 1ВМ
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Внутри каждого из пунктов выше каждый из сервисов изолировать с помощью контейнеризации, при этом данные писать на отдельный том. Сервисы не обьединять: один сервис, один контейнер. 
Физические сервера в нативном виде не использовал бы вообще, только для установки гипервизора и ВМ выше поверх него. Что касается ELK, все ноды на своих ВМ.

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

### Ответ:

Скачиваем образы:
```
vagrant@server1:/$ docker pull ubuntu
Using default tag: latest
latest: Pulling from library/ubuntu
08c01a0ec47e: Pull complete
Digest: sha256:669e010b58baf5beb2836b253c1fd5768333f0d1dbcb834f7c07a4dc93f474be
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest
vagrant@server1:/$ docker pull centos
Using default tag: latest
latest: Pulling from library/centos
a1d0c7532777: Pull complete
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
docker.io/library/centos:latest
```

Создаем тестовую директорию:
```
vagrant@server1:/$ sudo mkdir /test
vagrant@server1:~$ ls /data/
```

Запускаем контейнер с volume и создаем тестовый файл:
```
vagrant@server1:/$ docker run -it -v /data:/data ubuntu
root@e5c7162cd31e:/# cd /data/
root@e5c7162cd31e:/data# echo "TEST" > file1_test.txt
```

Выходим из контейнера ubuntu через Ctrl+p, Ctrl+q (для того, чтобы не убить контейнер/процесс). Создаем файл в тестовой директории и запускаем контейнер centos:
```
vagrant@server1:/$ echo "TEST2" | sudo tee /data/file2_test.txt
vagrant@server1:/$ docker run -it -v /data:/data centos
[root@850eb23c2024]# ls /data
file1_test.txt  file2_test.txt
[root@850eb23c2024]# cat /data/file1_test.txt
TEST
[root@850eb23c2024]# cat /data/file2_test.txt
TEST2
```

Выходим из контейнера centos через Ctrl+p, Ctrl+q. Проверяем что виртуалки запущены.
```
vagrant@server1:/data$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED              STATUS              PORTS     NAMES
850eb23c2024   centos    "/bin/bash"   About a minute ago   Up About a minute             busy_shaw
e5c7162cd31e   ubuntu    "bash"        4 minutes ago        Up 4 minutes                  reverent_poitras
```

PS: вывод ```ls /data``` чуть выше.

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.
Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

### Ответ:

Процедура сборки контейнера аналогична Задаче 1, за исключением другого Dockerfile (https://github.com/netology-code/virt-homeworks/blob/virt-11/05-virt-03-docker/src/build/ansible/Dockerfile).

```
vagrant@server1:~$ docker image ls
REPOSITORY                    TAG       IMAGE ID       CREATED        SIZE
dgolodnikov/ansible_devtest   1.0.0     456dbb0ab55a   10 hours ago   230MB
dgolodnikov/nginx_devtest     1.0.3     06ecd712ebf2   10 hours ago   142MB
nginx                         latest    c316d5a335a5   2 weeks ago    142MB
alpine                        3.14      0a97eee8041e   2 months ago   5.61MB
```

Ссылка на репозиторий: https://hub.docker.com/repository/docker/dgolodnikov/ansible_devtest