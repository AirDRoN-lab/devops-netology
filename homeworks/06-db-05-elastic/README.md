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

Т.к. elastic сам просит "max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]" добавим параметр на хостовой машине и перезагрузим машину:
```
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf 
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

vagrant@server1:~$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
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
```
curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 1,  "number_of_replicas": 0 }}}'
curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 2,  "number_of_replicas": 1 }}}'
curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 4,  "number_of_replicas": 2 }}}'


vagrant@server1:~$ curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 1,  "number_of_replicas": 0 }}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
vagrant@server1:~$ curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 2,  "number_of_replicas": 1 }}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
vagrant@server1:~$ curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 4,  "number_of_replicas": 2 }}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}


vagrant@server1:~$ curl -X GET "localhost:9200/ind-1,ind-2,ind-3?pretty"
{
  "ind-1" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "ind-1",
        "creation_date" : "1649703428017",
        "number_of_replicas" : "0",
        "uuid" : "ikd4reuLQT-4xGKe1LoSVQ",
        "version" : {
          "created" : "8010299"
        }
      }
    }
  },
  "ind-2" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "2",
        "provided_name" : "ind-2",
        "creation_date" : "1649703445700",
        "number_of_replicas" : "1",
        "uuid" : "X7tq8ESITJCEeIAmBWyWLg",
        "version" : {
          "created" : "8010299"
        }
      }
    }
  },
  "ind-3" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "4",
        "provided_name" : "ind-3",
        "creation_date" : "1649703447270",
        "number_of_replicas" : "2",
        "uuid" : "6vYsXa3HRGu7rzgGCwuDaA",
        "version" : {
          "created" : "8010299"
        }
      }
    }
  }
}


vagrant@server1:~$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}

vagrant@server1:~$ curl -X DELETE "localhost:9200/ind-1,ind-2,ind-3?pretty"
{
  "acknowledged" : true
}
```
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

Создаем директорию snapshot, назначем права для пользователя elasticsearch, добавляем настройки репозитория и рестартуем контейнер.

```
[root@4e2403202eaf /]# mkdir /elasticsearch-8.1.2/snapshots
[root@4e2403202eaf /]# echo "path.repo: /elasticsearch-8.1.2/snapshots" >> /elasticsearch-8.1.2/config/elasticsearch.yml
[root@4e2403202eaf /]# chown elasticsearch:elasticsearch /elasticsearch-8.1.2/snapshots
vagrant@server1:~$ docker restart 4e2403202eaf
```

Регистрируем директорию, как netology_backup через API и проверяем:
```
vagrant@server1:~$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'{"type": "fs","settings": {"location": "/elasticsearch-8.1.2/snapshots"}}'
{
	"acknowledged":true
}

vagrant@server1:~$ curl -X POST "localhost:9200/_snapshot/netology_backup/_verify?pretty"
{
  "nodes" : {
    "oGMcy-irQ_6Dy7GLFDb_-g" : {
      "name" : "netology.test"
    }
  }
}
```

Добавляем индекс test согласно задания и проверяем:
```
vagrant@server1:~$ curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 1,  "number_of_replicas": 0 }}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}

vagrant@server1:~$ curl -X GET "localhost:9200/_cat/indices?v=true"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  WacKW0EPRcubzJ62ug6N_w   1   0          0            0       225b           225b
```

Делаем бекап в netology_backup (добавили ?wait_for_completion=true для визуального понимания завершения) и делаем проверку:
```
vagrant@server1:~$ curl -X PUT "localhost:9200/_snapshot/netology_backup/my_snapshot?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "my_snapshot",
    "uuid" : "GBVmio8OSEy9NCV7P6Z5IQ",
    "repository" : "netology_backup",
    "version_id" : 8010299,
    "version" : "8.1.2",
    "indices" : [
      "test",
      ".geoip_databases"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2022-04-12T10:02:51.237Z",
    "start_time_in_millis" : 1649757771237,
    "end_time" : "2022-04-12T10:02:54.050Z",
    "end_time_in_millis" : 1649757774050,
    "duration_in_millis" : 2813,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}

vagrant@server1:~$ curl -X GET "localhost:9200/_snapshot?pretty"
{
  "netology_backup" : {
    "type" : "fs",
    "uuid" : "ywzN4Ch5RnSRyl7aL19P1A",
    "settings" : {
      "location" : "/elasticsearch-8.1.2/snapshots"
    }
  }
}

vagrant@server1:~$ curl -X GET "localhost:9200/_snapshot/netology_backup/*?verbose=false&pretty"
{
  "snapshots" : [
    {
      "snapshot" : "my_snapshot",
      "uuid" : "GBVmio8OSEy9NCV7P6Z5IQ",
      "repository" : "netology_backup",
      "indices" : [
        ".geoip_databases",
        "test"
      ],
      "data_streams" : [ ],
      "state" : "SUCCESS"
    }
  ],
  "total" : 1,
  "remaining" : 0
}

```
Проверяем директорию /elasticsearch-8.1.2/snapshots/ внутри контейнера:
```
[root@4e2403202eaf /]# ls -la /elasticsearch-8.1.2/snapshots/
total 48
drwxr-xr-x 3 elasticsearch elasticsearch  4096 Apr 12 10:02 .
drwxr-xr-x 1 elasticsearch elasticsearch  4096 Apr 12 09:46 ..
-rw-rw-r-- 1 elasticsearch elasticsearch   844 Apr 12 10:02 index-0
-rw-rw-r-- 1 elasticsearch elasticsearch     8 Apr 12 10:02 index.latest
drwxrwxr-x 4 elasticsearch elasticsearch  4096 Apr 12 10:02 indices
-rw-rw-r-- 1 elasticsearch elasticsearch 18351 Apr 12 10:02 meta-GBVmio8OSEy9NCV7P6Z5IQ.dat
-rw-rw-r-- 1 elasticsearch elasticsearch   354 Apr 12 10:02 snap-GBVmio8OSEy9NCV7P6Z5IQ.dat
```

Удаляем индекс test:
```
vagrant@server1:~$ curl -X DELETE "localhost:9200/test?pretty"
{
  "acknowledged" : true
}

```

Создаем индекс test-2 и проверяем список:
```
vagrant@server1:~$ curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 1,  "number_of_replicas": 0 }}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}

vagrant@server1:~$ curl -X GET "localhost:9200/_cat/indices?v=true"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 0gEIXCwUQRaAAu9MgWqQeA   1   0          0            0       225b           225b
```

Выполняем восстанавление из бекапа:
```
vagrant@server1:~$ curl -X POST "localhost:9200/_snapshot/netology_backup/my_snapshot/_restore?pretty" -H 'Content-Type: application/json' -d' { "indices": "*", "include_global_state": true } '
{
  "accepted" : true
}
```

Проверяем список индексов и видем два индекса. Один созданный test-2 и восстановленный из бекапа. Все ОК!:
```
vagrant@server1:~$ curl -X GET "localhost:9200/_cat/indices?v=true"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 0gEIXCwUQRaAAu9MgWqQeA   1   0          0            0       225b           225b
green  open   test   c0Yjw3qcRA6XbOfbyL96hg   1   0          0            0       225b           225b
```
Домашка готова!
