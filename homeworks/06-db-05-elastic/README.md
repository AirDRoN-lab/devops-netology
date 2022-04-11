# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Ответ

Для понимания, что необходимо прописывать в Docker-файл, соберем сначала всю конструкцию внутри контейнера centos.
Для установки необходимо установить wget в контейнер.

```
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
#yum update -y #можно и не обновялять, но желательно
yum install -y wget
```
В связи с тем, что есть проблема с доступом к архиву ELastic из России (ошибка 402 Forbidden). Зеркало было найдено здесь (sha512 сумма совпадает с целевой):
```
wget https://fossies.org/linux/www/elasticsearch-8.1.2-linux-x86_64.tar.gz
```
Далее следуюем инструкции (см. выше) по установке Elasicsearch из архива:

```
wget https://fossies.org/linux/www/elasticsearch-8.1.2-linux-x86_64.tar.gz
tar -xzf elasticsearch-8.1.2-linux-x86_64.tar.gz

```
Согласно ТЗ изменяем имя ноды и изменяем path.data. Кроме этого, отключаем secutity для облегчения работы с контейнером в дальнейшем. В ТЗ не требуется обеспечения шифрования:

```
echo "node.name: netology.test" >> /elasticsearch-8.1.2/config/elasticsearch.yml
echo "path.data: /var/lib/elastic" >> /elasticsearch-8.1.2/config/elasticsearch.yml
echo "xpack.security.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
echo "xpack.security.enrollment.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
echo "xpack.security.http.ssl.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
echo "xpack.security.transport.ssl.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
```

Создаем пользовтаеля и группу elastcisearch, т.к. из под root elasticsearch не запускается.

```
groupadd elasticsearch
useradd elasticsearch -g elasticsearch -p elasticsearch

mkdir /var/lib/elastic
chown -R elasticsearch:elasticsearch /elasticsearch-8.1.2 /var/lib/elastic
chmod o+x /elasticsearch-8.1.2 /var/lib/elastic
chgrp elasticsearch /elasticsearch-8.1.2 /var/lib/elastic

```
Запускаем из под пользователя elasticsearch (для того, чтобы запустить в качестве демона добавляем ключ -d в конце):

```
su - elasticsearch -c "/elasticsearch-8.1.2/bin/elasticsearch -d"
```

Проверяем:

```
[root@b8e8b74773b1 config]# curl localhost:9200
{
  "name" : "netology.test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "wS_9NjUyQ7uYtLyytu04cQ",
  "version" : {
    "number" : "8.1.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "31df9689e80bad366ac20176aa7f2371ea5eb4c1",
    "build_date" : "2022-03-29T21:18:59.991429448Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}

[root@b8e8b74773b1 config]# curl localhost:9200/_cat/shards
.geoip_databases 0 p STARTED   127.0.0.1 netology.test

[root@b8e8b74773b1 config]# curl localhost:9200/_cluster/health
{"cluster_name":"elasticsearch","status":"green","timed_out":false,"number_of_nodes":1,"number_of_data_nodes":1,"active_primary_shards":1,"active_shards":1,"relocating_shards":0,"initializing_shards":0,"unassigned_shards":0,"delayed_unassigned_shards":0,"number_of_pending_tasks":0,"number_of_in_flight_fetch":0,"task_max_waiting_in_queue_millis":0,"active_shards_percent_as_number":100.0}
```

Приступаем к сборке контейнера, формируем Docker файл вида:
```
vagrant@server1:~$ cat Dockerfile
FROM centos:latest

RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
#RUN yum update -y # не будем обновлять, и так не шибко старое. 
RUN yum install -y wget
RUN wget https://fossies.org/linux/www/elasticsearch-8.1.2-linux-x86_64.tar.gz
RUN tar -xzf elasticsearch-8.1.2-linux-x86_64.tar.gz
RUN echo "node.name: netology.test" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "path.data: /var/lib/elastic" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "xpack.security.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "xpack.security.enrollment.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "xpack.security.http.ssl.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "xpack.security.transport.ssl.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "network.host: 0.0.0.0" >> /elasticsearch-8.1.2/config/elasticsearch.yml # чтобы не только localhost
RUN echo "discovery.type: single-node" >> /elasticsearch-8.1.2/config/elasticsearch.yml # в противном случае не запускается

# т.к. elastic сам просит "max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]" добавим:
RUN echo "vm.max_map_count = 262144" >> /etc/sysctl.conf 

RUN groupadd elasticsearch
RUN useradd elasticsearch -g elasticsearch -p elasticsearch
RUN mkdir /var/lib/elastic
RUN chown -R elasticsearch:elasticsearch /elasticsearch-8.1.2 /var/lib/elastic
RUN chmod o+x /elasticsearch-8.1.2 /var/lib/elastic
RUN chgrp elasticsearch /elasticsearch-8.1.2 /var/lib/elastic
CMD su - elasticsearch -c /elasticsearch-8.1.2/bin/elasticsearch 
```

Выполняем сборку:
```
vagrant@server1:~$ DOCKER_BUILDKIT=0 docker build -t dgolodnikov/elasticsearch_devtest:1.0.3 .
vagrant@server1:~$ docker image list | grep elastic
dgolodnikov/elasticsearch_devtest   1.0.3     16def2d53a99   14 hours ago   2.99GB
```

Запускаем:
```
vagrant@server1:~$ docker run -it -p 9200:9200 -d  dgolodnikov/elasticsearch_devtest:1.0.3 
4e2403202eaf17e14e07bddfb2383926e6ba5d544efd7f08a6102491576621ee
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE                                     COMMAND                  CREATED              STATUS              PORTS                                       NAMES
4e2403202eaf   dgolodnikov/elasticsearch_devtest:1.0.3   "/bin/sh -c 'su - el…"   About a minute ago   Up About a minute   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp lasta
```

Проверяем, выполняем пару API запросов:
```
vagrant@server1:~$ curl localhost:9200
{
  "name" : "netology.test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "CE4_K6_pSx-TgoasI5Hgrg",
  "version" : {
    "number" : "8.1.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "31df9689e80bad366ac20176aa7f2371ea5eb4c1",
    "build_date" : "2022-03-29T21:18:59.991429448Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
vagrant@server1:~$ curl localhost:9200/_cat/shards
.geoip_databases 0 p STARTED   172.17.0.2 netology.test
vagrant@server1:~$ curl localhost:9200/_cluster/health
{"cluster_name":"elasticsearch","status":"green","timed_out":false,"number_of_nodes":1,"number_of_data_nodes":1,"active_primary_shards":1,"active_shards":1,"relocating_shards":0,"initializing_shards":0,"unassigned_shards":0,"delayed_unassigned_shards":0,"number_of_pending_tasks":0,"number_of_in_flight_fetch":0,"task_max_waiting_in_queue_millis":0,"active_shards_percent_as_number":100.0}
```

Выполняем docker push на докерхаб, согласно задания. 

```
vagrant@server1:~$ docker push dgolodnikov/elasticsearch_devtest:1.0.3
The push refers to repository [docker.io/dgolodnikov/elasticsearch_devtest]
f7d348153649: Pushed 
34f92665dab9: Pushed 
8cf0190685d7: Pushed 
17a68d159087: Layer already exists 
...
1.0.3: digest: sha256:93a53b0db2e7b9fea3107fbe8b41e727b1721d94cc0da54a2118bfc496a6b042 size: 5324
```
Ссылки на контейнер: "docker pull dgolodnikov/elasticsearch_devtest:1.0.3" или "https://hub.docker.com/r/dgolodnikov/elasticsearch_devtest/tags"

PS: для запуска с сертификатом (пароль на пользователя elastic указывается при запуске)
```
[root@470df12af342 /]# curl --cacert /elasticsearch-8.1.2/config/certs/http_ca.crt -u elastic:password https://localhost:9200
Enter host password for user 'elastic':
{
  "name" : "netology.test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "Ctebdx-EQ5OZSxJGoYqTvA",
  "version" : {
    "number" : "8.1.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "31df9689e80bad366ac20176aa7f2371ea5eb4c1",
    "build_date" : "2022-03-29T21:18:59.991429448Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}

```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Ответ

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

## Ответ
