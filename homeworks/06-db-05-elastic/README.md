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

Не применился параметр vm.max_map_count:
```
[root@4e2403202eaf /]# sysctl -a | grep max_map
sysctl: reading key "kernel.unprivileged_userns_apparmor_policy"
vm.max_map_count = 65530
```
Но при этом:
```
[root@4e2403202eaf /]# cat /etc/sysctl.conf | grep map
vm.max_map_count = 262144
```
Причина пока не ясна =)

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

vagrant@server1:~$ curl -X GET "localhost:9200/_nodes?pretty"
{
  "_nodes" : {
    "total" : 1,
    "successful" : 1,
    "failed" : 0
  },
  "cluster_name" : "elasticsearch",
  "nodes" : {
    "oGMcy-irQ_6Dy7GLFDb_-g" : {
      "name" : "netology.test",
      "transport_address" : "172.17.0.2:9300",
      "host" : "172.17.0.2",
      "ip" : "172.17.0.2",
      "version" : "8.1.2",
      "build_flavor" : "default",
      "build_type" : "tar",
      "build_hash" : "31df9689e80bad366ac20176aa7f2371ea5eb4c1",
      "total_indexing_buffer" : 50331648,
      "roles" : [
        "data",
        "data_cold",
        "data_content",
        "data_frozen",
        "data_hot",
        "data_warm",
        "ingest",
        "master",
        "ml",
        "remote_cluster_client",
        "transform"
      ],
      "attributes" : {
        "ml.machine_memory" : "1028915200",
        "xpack.installed" : "true",
        "ml.max_jvm_size" : "411041792"
      },
      "settings" : {
        "cluster" : {
          "name" : "elasticsearch",
          "election" : {
            "strategy" : "supports_voting_only"
          }
        },
        "node" : {
          "attr" : {
            "xpack" : {
              "installed" : "true"
            },
            "ml" : {
              "max_jvm_size" : "411041792",
              "machine_memory" : "1028915200"
            }
          },
          "name" : "netology.test"
        },
        "path" : {
          "data" : "/var/lib/elastic",
          "logs" : "/elasticsearch-8.1.2/logs",
          "home" : "/elasticsearch-8.1.2"
        },
        "discovery" : {
          "type" : "single-node"
        },
        "client" : {
          "type" : "node"
        },
        "http" : {
          "type" : {
            "default" : "netty4"
          }
        },
        "transport" : {
          "type" : {
            "default" : "netty4"
          }
        },
        "xpack" : {
          "security" : {
            "http" : {
              "ssl" : {
                "enabled" : "false"
              }
            },
            "transport" : {
              "ssl" : {
                "enabled" : "false"
              }
            },
            "enabled" : "false",
            "enrollment" : {
              "enabled" : "false"
            }
          }
        },
        "network" : {
          "host" : "0.0.0.0"
        }
      },
      "os" : {
        "refresh_interval_in_millis" : 1000,
        "name" : "Linux",
        "pretty_name" : "CentOS Linux 8",
        "arch" : "amd64",
        "version" : "5.4.0-91-generic",
        "available_processors" : 1,
        "allocated_processors" : 1
      },
      "process" : {
        "refresh_interval_in_millis" : 1000,
        "id" : 6,
        "mlockall" : false
      },
      "jvm" : {
        "pid" : 6,
        "version" : "17.0.2",
        "vm_name" : "OpenJDK 64-Bit Server VM",
        "vm_version" : "17.0.2+8",
        "vm_vendor" : "Eclipse Adoptium",
        "bundled_jdk" : true,
        "using_bundled_jdk" : true,
        "start_time_in_millis" : 1649661917081,
        "mem" : {
          "heap_init_in_bytes" : 411041792,
          "heap_max_in_bytes" : 411041792,
          "non_heap_init_in_bytes" : 7667712,
          "non_heap_max_in_bytes" : 0,
          "direct_max_in_bytes" : 0
        },
        "gc_collectors" : [
          "G1 Young Generation",
          "G1 Old Generation"
        ],
        "memory_pools" : [
          "CodeHeap 'non-nmethods'",
          "Metaspace",
          "CodeHeap 'profiled nmethods'",
          "Compressed Class Space",
          "G1 Eden Space",
          "G1 Old Gen",
          "G1 Survivor Space",
          "CodeHeap 'non-profiled nmethods'"
        ],
        "using_compressed_ordinary_object_pointers" : "true",
        "input_arguments" : [
          "-Xshare:auto",
          "-Des.networkaddress.cache.ttl=60",
          "-Des.networkaddress.cache.negative.ttl=10",
          "-Djava.security.manager=allow",
          "-XX:+AlwaysPreTouch",
          "-Xss1m",
          "-Djava.awt.headless=true",
          "-Dfile.encoding=UTF-8",
          "-Djna.nosys=true",
          "-XX:-OmitStackTraceInFastThrow",
          "-XX:+ShowCodeDetailsInExceptionMessages",
          "-Dio.netty.noUnsafe=true",
          "-Dio.netty.noKeySetOptimization=true",
          "-Dio.netty.recycler.maxCapacityPerThread=0",
          "-Dio.netty.allocator.numDirectArenas=0",
          "-Dlog4j.shutdownHookEnabled=false",
          "-Dlog4j2.disable.jmx=true",
          "-Dlog4j2.formatMsgNoLookups=true",
          "-Djava.locale.providers=SPI,COMPAT",
          "--add-opens=java.base/java.io=ALL-UNNAMED",
          "-XX:+UseG1GC",
          "-Djava.io.tmpdir=/tmp/elasticsearch-6316029104671557045",
          "-XX:+HeapDumpOnOutOfMemoryError",
          "-XX:+ExitOnOutOfMemoryError",
          "-XX:HeapDumpPath=data",
          "-XX:ErrorFile=logs/hs_err_pid%p.log",
          "-Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m",
          "-Xms392m",
          "-Xmx392m",
          "-XX:MaxDirectMemorySize=205520896",
          "-XX:G1HeapRegionSize=4m",
          "-XX:InitiatingHeapOccupancyPercent=30",
          "-XX:G1ReservePercent=15",
          "-Des.path.home=/elasticsearch-8.1.2",
          "-Des.path.conf=/elasticsearch-8.1.2/config",
          "-Des.distribution.flavor=default",
          "-Des.distribution.type=tar",
          "-Des.bundled_jdk=true"
        ]
      },
      "thread_pool" : {
        "force_merge" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : -1
        },
        "search_coordination" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 1000
        },
        "ml_datafeed" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 512,
          "keep_alive" : "1m",
          "queue_size" : -1
        },
        "searchable_snapshots_cache_fetch_async" : {
          "type" : "scaling",
          "core" : 0,
          "max" : 3,
          "keep_alive" : "30s",
          "queue_size" : -1
        },
        "snapshot_meta" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 3,
          "keep_alive" : "30s",
          "queue_size" : -1
        },
        "fetch_shard_started" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 2,
          "keep_alive" : "5m",
          "queue_size" : -1
        },
        "rollup_indexing" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : -1
        },
        "search" : {
          "type" : "fixed",
          "size" : 2,
          "queue_size" : 1000
        },
        "ccr" : {
          "type" : "fixed",
          "size" : 32,
          "queue_size" : 100
        },
        "flush" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 1,
          "keep_alive" : "5m",
          "queue_size" : -1
        },
        "fetch_shard_store" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 2,
          "keep_alive" : "5m",
          "queue_size" : -1
        },
        "ml_utility" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 2048,
          "keep_alive" : "10m",
          "queue_size" : -1
        },
        "get" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 1000
        },
        "system_read" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 2000
        },
        "system_critical_read" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 2000
        },
        "write" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 10000
        },
        "watcher" : {
          "type" : "fixed",
          "size" : 5,
          "queue_size" : 1000
        },
        "system_critical_write" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 1500
        },
        "refresh" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 1,
          "keep_alive" : "5m",
          "queue_size" : -1
        },
        "repository_azure" : {
          "type" : "scaling",
          "core" : 0,
          "max" : 5,
          "keep_alive" : "30s",
          "queue_size" : -1
        },
        "vector_tile_generation" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : -1
        },
        "system_write" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 1000
        },
        "generic" : {
          "type" : "scaling",
          "core" : 4,
          "max" : 128,
          "keep_alive" : "30s",
          "queue_size" : -1
        },
        "warmer" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 1,
          "keep_alive" : "5m",
          "queue_size" : -1
        },
        "auto_complete" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 100
        },
        "azure_event_loop" : {
          "type" : "scaling",
          "core" : 0,
          "max" : 1,
          "keep_alive" : "30s",
          "queue_size" : -1
        },
        "management" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 1,
          "keep_alive" : "5m",
          "queue_size" : -1
        },
        "analyze" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 16
        },
        "searchable_snapshots_cache_prewarming" : {
          "type" : "scaling",
          "core" : 0,
          "max" : 16,
          "keep_alive" : "30s",
          "queue_size" : -1
        },
        "ml_job_comms" : {
          "type" : "scaling",
          "core" : 4,
          "max" : 2048,
          "keep_alive" : "1m",
          "queue_size" : -1
        },
        "snapshot" : {
          "type" : "scaling",
          "core" : 1,
          "max" : 1,
          "keep_alive" : "5m",
          "queue_size" : -1
        },
        "search_throttled" : {
          "type" : "fixed",
          "size" : 1,
          "queue_size" : 100
        }
      },
      "transport" : {
        "bound_address" : [
          "0.0.0.0:9300"
        ],
        "publish_address" : "172.17.0.2:9300",
        "profiles" : { }
      },
      "http" : {
        "bound_address" : [
          "0.0.0.0:9200"
        ],
        "publish_address" : "172.17.0.2:9200",
        "max_content_length_in_bytes" : 104857600
      },
      "plugins" : [ ],
      "modules" : [
        {
          "name" : "aggs-matrix-stats",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Adds aggregations whose input are a list of numeric fields and output includes a matrix.",
          "classname" : "org.elasticsearch.search.aggregations.matrix.MatrixAggregationPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "analysis-common",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Adds \"built in\" analyzers to Elasticsearch.",
          "classname" : "org.elasticsearch.analysis.common.CommonAnalysisPlugin",
          "extended_plugins" : [
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "constant-keyword",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Module for the constant-keyword field type, which is a specialization of keyword for the case when all documents have the same value.",
          "classname" : "org.elasticsearch.xpack.constantkeyword.ConstantKeywordMapperPlugin",
          "extended_plugins" : [
            "x-pack-core",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "data-streams",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Data Streams",
          "classname" : "org.elasticsearch.datastreams.DataStreamsPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "frozen-indices",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for the frozen indices functionality",
          "classname" : "org.elasticsearch.xpack.frozen.FrozenIndices",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "ingest-common",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Module for ingest processors that do not require additional security permissions or have large dependencies and resources",
          "classname" : "org.elasticsearch.ingest.common.IngestCommonPlugin",
          "extended_plugins" : [
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "ingest-geoip",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Ingest processor that uses lookup geo data based on IP addresses using the MaxMind geo database",
          "classname" : "org.elasticsearch.ingest.geoip.IngestGeoIpPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "ingest-user-agent",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Ingest processor that extracts information from a user agent",
          "classname" : "org.elasticsearch.ingest.useragent.IngestUserAgentPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "kibana",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Plugin exposing APIs for Kibana system indices",
          "classname" : "org.elasticsearch.kibana.KibanaPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "lang-expression",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Lucene expressions integration for Elasticsearch",
          "classname" : "org.elasticsearch.script.expression.ExpressionPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "lang-mustache",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Mustache scripting integration for Elasticsearch",
          "classname" : "org.elasticsearch.script.mustache.MustachePlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "lang-painless",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "An easy, safe and fast scripting language for Elasticsearch",
          "classname" : "org.elasticsearch.painless.PainlessPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "legacy-geo",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Placeholder plugin for geospatial features in ES",
          "classname" : "org.elasticsearch.legacygeo.LegacyGeoPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "mapper-extras",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Adds advanced field mappers",
          "classname" : "org.elasticsearch.index.mapper.extras.MapperExtrasPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "mapper-version",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for a field type to store software versions",
          "classname" : "org.elasticsearch.xpack.versionfield.VersionFieldPlugin",
          "extended_plugins" : [
            "x-pack-core",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "old-lucene-versions",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for accessing older Lucene indices",
          "classname" : "org.elasticsearch.xpack.lucene.bwc.OldLuceneVersions",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "parent-join",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "This module adds the support parent-child queries and aggregations",
          "classname" : "org.elasticsearch.join.ParentJoinPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "percolator",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Percolator module adds capability to index queries and query these queries by specifying documents",
          "classname" : "org.elasticsearch.percolator.PercolatorPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "rank-eval",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "The Rank Eval module adds APIs to evaluate ranking quality.",
          "classname" : "org.elasticsearch.index.rankeval.RankEvalPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "reindex",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "The Reindex module adds APIs to reindex from one index to another or update documents in place.",
          "classname" : "org.elasticsearch.reindex.ReindexPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "repositories-metering-api",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Repositories metering API",
          "classname" : "org.elasticsearch.xpack.repositories.metering.RepositoriesMeteringPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "repository-azure",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "The Azure Repository plugin adds support for Azure storage repositories.",
          "classname" : "org.elasticsearch.repositories.azure.AzureRepositoryPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "repository-encrypted",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - client-side encrypted repositories.",
          "classname" : "org.elasticsearch.repositories.encrypted.EncryptedRepositoryPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "repository-gcs",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "The GCS repository plugin adds Google Cloud Storage support for repositories.",
          "classname" : "org.elasticsearch.repositories.gcs.GoogleCloudStoragePlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "repository-s3",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "The S3 repository plugin adds S3 repositories",
          "classname" : "org.elasticsearch.repositories.s3.S3RepositoryPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "repository-url",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Module for URL repository",
          "classname" : "org.elasticsearch.plugin.repository.url.URLRepositoryPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "runtime-fields-common",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Module for runtime fields features and extensions that have large dependencies",
          "classname" : "org.elasticsearch.runtimefields.RuntimeFieldsCommonPlugin",
          "extended_plugins" : [
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "search-business-rules",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for applying business rules to search result rankings",
          "classname" : "org.elasticsearch.xpack.searchbusinessrules.SearchBusinessRules",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "searchable-snapshots",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for the searchable snapshots functionality",
          "classname" : "org.elasticsearch.xpack.searchablesnapshots.SearchableSnapshots",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "snapshot-based-recoveries",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin that enables snapshot based recoveries",
          "classname" : "org.elasticsearch.xpack.snapshotbasedrecoveries.SnapshotBasedRecoveriesPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "snapshot-repo-test-kit",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for a test kit for snapshot repositories",
          "classname" : "org.elasticsearch.repositories.blobstore.testkit.SnapshotRepositoryTestKit",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "spatial",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for Basic Spatial features",
          "classname" : "org.elasticsearch.xpack.spatial.SpatialPlugin",
          "extended_plugins" : [
            "x-pack-core",
            "legacy-geo",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "transform",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin to transform data",
          "classname" : "org.elasticsearch.xpack.transform.Transform",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "transport-netty4",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Netty 4 based transport implementation",
          "classname" : "org.elasticsearch.transport.netty4.Netty4Plugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "unsigned-long",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Module for the unsigned long field type",
          "classname" : "org.elasticsearch.xpack.unsignedlong.UnsignedLongMapperPlugin",
          "extended_plugins" : [
            "x-pack-core",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "vector-tile",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for mapbox vector tile features",
          "classname" : "org.elasticsearch.xpack.vectortile.VectorTilePlugin",
          "extended_plugins" : [
            "spatial"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "vectors",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for working with vectors",
          "classname" : "org.elasticsearch.xpack.vectors.DenseVectorPlugin",
          "extended_plugins" : [
            "x-pack-core",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "wildcard",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A plugin for a keyword field type with efficient wildcard search",
          "classname" : "org.elasticsearch.xpack.wildcard.Wildcard",
          "extended_plugins" : [
            "x-pack-core",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-aggregate-metric",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Module for the aggregate_metric field type, which allows pre-aggregated fields to be stored a single field.",
          "classname" : "org.elasticsearch.xpack.aggregatemetric.AggregateMetricMapperPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-analytics",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Analytics",
          "classname" : "org.elasticsearch.xpack.analytics.AnalyticsPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-async",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A module which handles common async operations",
          "classname" : "org.elasticsearch.xpack.async.AsyncResultsIndexPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-async-search",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "A module which allows to track the progress of a search asynchronously.",
          "classname" : "org.elasticsearch.xpack.search.AsyncSearch",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-autoscaling",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Autoscaling",
          "classname" : "org.elasticsearch.xpack.autoscaling.Autoscaling",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-ccr",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - CCR",
          "classname" : "org.elasticsearch.xpack.ccr.Ccr",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-core",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Core",
          "classname" : "org.elasticsearch.xpack.core.XPackPlugin",
          "extended_plugins" : [ ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-deprecation",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Deprecation",
          "classname" : "org.elasticsearch.xpack.deprecation.Deprecation",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-enrich",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Enrich",
          "classname" : "org.elasticsearch.xpack.enrich.EnrichPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-eql",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "The Elasticsearch plugin that powers EQL for Elasticsearch",
          "classname" : "org.elasticsearch.xpack.eql.plugin.EqlPlugin",
          "extended_plugins" : [
            "x-pack-ql",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-fleet",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Plugin exposing APIs for Fleet system indices",
          "classname" : "org.elasticsearch.xpack.fleet.Fleet",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-graph",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Graph",
          "classname" : "org.elasticsearch.xpack.graph.Graph",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-identity-provider",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Identity Provider",
          "classname" : "org.elasticsearch.xpack.idp.IdentityProviderPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-ilm",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Index Lifecycle Management",
          "classname" : "org.elasticsearch.xpack.ilm.IndexLifecycle",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-logstash",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Logstash",
          "classname" : "org.elasticsearch.xpack.logstash.Logstash",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-ml",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Machine Learning",
          "classname" : "org.elasticsearch.xpack.ml.MachineLearning",
          "extended_plugins" : [
            "x-pack-autoscaling",
            "lang-painless"
          ],
          "has_native_controller" : true,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-monitoring",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Monitoring",
          "classname" : "org.elasticsearch.xpack.monitoring.Monitoring",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-ql",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch infrastructure plugin for EQL and SQL for Elasticsearch",
          "classname" : "org.elasticsearch.xpack.ql.plugin.QlPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-rollup",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Rollup",
          "classname" : "org.elasticsearch.xpack.rollup.Rollup",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-security",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Security",
          "classname" : "org.elasticsearch.xpack.security.Security",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-shutdown",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Shutdown",
          "classname" : "org.elasticsearch.xpack.shutdown.ShutdownPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-sql",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "The Elasticsearch plugin that powers SQL for Elasticsearch",
          "classname" : "org.elasticsearch.xpack.sql.plugin.SqlPlugin",
          "extended_plugins" : [
            "x-pack-ql",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-stack",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Stack",
          "classname" : "org.elasticsearch.xpack.stack.StackPlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-text-structure",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Text Structure",
          "classname" : "org.elasticsearch.xpack.textstructure.TextStructurePlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-voting-only-node",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Voting-only node",
          "classname" : "org.elasticsearch.cluster.coordination.votingonly.VotingOnlyNodePlugin",
          "extended_plugins" : [
            "x-pack-core"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        },
        {
          "name" : "x-pack-watcher",
          "version" : "8.1.2",
          "elasticsearch_version" : "8.1.2",
          "java_version" : "17",
          "description" : "Elasticsearch Expanded Pack Plugin - Watcher",
          "classname" : "org.elasticsearch.xpack.watcher.Watcher",
          "extended_plugins" : [
            "x-pack-core",
            "lang-painless"
          ],
          "has_native_controller" : false,
          "licensed" : false,
          "type" : "isolated"
        }
      ],
      "ingest" : {
        "processors" : [
          {
            "type" : "append"
          },
          {
            "type" : "bytes"
          },
          {
            "type" : "circle"
          },
          {
            "type" : "community_id"
          },
          {
            "type" : "convert"
          },
          {
            "type" : "csv"
          },
          {
            "type" : "date"
          },
          {
            "type" : "date_index_name"
          },
          {
            "type" : "dissect"
          },
          {
            "type" : "dot_expander"
          },
          {
            "type" : "drop"
          },
          {
            "type" : "enrich"
          },
          {
            "type" : "fail"
          },
          {
            "type" : "fingerprint"
          },
          {
            "type" : "foreach"
          },
          {
            "type" : "geoip"
          },
          {
            "type" : "grok"
          },
          {
            "type" : "gsub"
          },
          {
            "type" : "html_strip"
          },
          {
            "type" : "inference"
          },
          {
            "type" : "join"
          },
          {
            "type" : "json"
          },
          {
            "type" : "kv"
          },
          {
            "type" : "lowercase"
          },
          {
            "type" : "network_direction"
          },
          {
            "type" : "pipeline"
          },
          {
            "type" : "registered_domain"
          },
          {
            "type" : "remove"
          },
          {
            "type" : "rename"
          },
          {
            "type" : "script"
          },
          {
            "type" : "set"
          },
          {
            "type" : "set_security_user"
          },
          {
            "type" : "sort"
          },
          {
            "type" : "split"
          },
          {
            "type" : "trim"
          },
          {
            "type" : "uppercase"
          },
          {
            "type" : "uri_parts"
          },
          {
            "type" : "urldecode"
          },
          {
            "type" : "user_agent"
          }
        ]
      },
      "aggregations" : {
        "adjacency_matrix" : {
          "types" : [
            "other"
          ]
        },
        "auto_date_histogram" : {
          "types" : [
            "boolean",
            "date",
            "numeric"
          ]
        },
        "avg" : {
          "types" : [
            "aggregate_metric",
            "boolean",
            "date",
            "histogram",
            "numeric"
          ]
        },
        "boxplot" : {
          "types" : [
            "histogram",
            "numeric"
          ]
        },
        "cardinality" : {
          "types" : [
            "boolean",
            "date",
            "geopoint",
            "geoshape",
            "ip",
            "keyword",
            "numeric",
            "range"
          ]
        },
        "categorize_text" : {
          "types" : [
            "other"
          ]
        },
        "children" : {
          "types" : [
            "other"
          ]
        },
        "composite" : {
          "types" : [
            "other"
          ]
        },
        "date_histogram" : {
          "types" : [
            "boolean",
            "date",
            "numeric",
            "range"
          ]
        },
        "date_range" : {
          "types" : [
            "boolean",
            "date",
            "numeric"
          ]
        },
        "diversified_sampler" : {
          "types" : [
            "boolean",
            "date",
            "keyword",
            "numeric"
          ]
        },
        "extended_stats" : {
          "types" : [
            "boolean",
            "date",
            "numeric"
          ]
        },
        "filter" : {
          "types" : [
            "other"
          ]
        },
        "filters" : {
          "types" : [
            "other"
          ]
        },
        "geo_bounds" : {
          "types" : [
            "geopoint",
            "geoshape"
          ]
        },
        "geo_centroid" : {
          "types" : [
            "geopoint",
            "geoshape"
          ]
        },
        "geo_distance" : {
          "types" : [
            "geopoint"
          ]
        },
        "geo_line" : {
          "types" : [
            "geopoint"
          ]
        },
        "geohash_grid" : {
          "types" : [
            "geopoint",
            "geoshape"
          ]
        },
        "geohex_grid" : {
          "types" : [
            "geopoint"
          ]
        },
        "geotile_grid" : {
          "types" : [
            "geopoint",
            "geoshape"
          ]
        },
        "global" : {
          "types" : [
            "other"
          ]
        },
        "histogram" : {
          "types" : [
            "boolean",
            "date",
            "histogram",
            "numeric",
            "range"
          ]
        },
        "ip_prefix" : {
          "types" : [
            "ip"
          ]
        },
        "ip_range" : {
          "types" : [
            "ip"
          ]
        },
        "matrix_stats" : {
          "types" : [
            "other"
          ]
        },
        "max" : {
          "types" : [
            "aggregate_metric",
            "boolean",
            "date",
            "histogram",
            "numeric"
          ]
        },
        "median_absolute_deviation" : {
          "types" : [
            "numeric"
          ]
        },
        "min" : {
          "types" : [
            "aggregate_metric",
            "boolean",
            "date",
            "histogram",
            "numeric"
          ]
        },
        "missing" : {
          "types" : [
            "boolean",
            "date",
            "geopoint",
            "ip",
            "keyword",
            "numeric",
            "range"
          ]
        },
        "multi_terms" : {
          "types" : [
            "other"
          ]
        },
        "nested" : {
          "types" : [
            "other"
          ]
        },
        "parent" : {
          "types" : [
            "other"
          ]
        },
        "percentile_ranks" : {
          "types" : [
            "boolean",
            "date",
            "histogram",
            "numeric"
          ]
        },
        "percentiles" : {
          "types" : [
            "boolean",
            "date",
            "histogram",
            "numeric"
          ]
        },
        "range" : {
          "types" : [
            "boolean",
            "date",
            "histogram",
            "numeric"
          ]
        },
        "rare_terms" : {
          "types" : [
            "boolean",
            "date",
            "ip",
            "keyword",
            "numeric"
          ]
        },
        "rate" : {
          "types" : [
            "histogram",
            "numeric"
          ]
        },
        "reverse_nested" : {
          "types" : [
            "other"
          ]
        },
        "sampler" : {
          "types" : [
            "other"
          ]
        },
        "scripted_metric" : {
          "types" : [
            "other"
          ]
        },
        "significant_terms" : {
          "types" : [
            "boolean",
            "date",
            "ip",
            "keyword",
            "numeric"
          ]
        },
        "significant_text" : {
          "types" : [
            "other"
          ]
        },
        "stats" : {
          "types" : [
            "boolean",
            "date",
            "numeric"
          ]
        },
        "string_stats" : {
          "types" : [
            "keyword"
          ]
        },
        "sum" : {
          "types" : [
            "aggregate_metric",
            "boolean",
            "date",
            "histogram",
            "numeric"
          ]
        },
        "t_test" : {
          "types" : [
            "numeric"
          ]
        },
        "terms" : {
          "types" : [
            "boolean",
            "date",
            "ip",
            "keyword",
            "numeric"
          ]
        },
        "top_hits" : {
          "types" : [
            "other"
          ]
        },
        "top_metrics" : {
          "types" : [
            "other"
          ]
        },
        "value_count" : {
          "types" : [
            "aggregate_metric",
            "boolean",
            "date",
            "geopoint",
            "geoshape",
            "histogram",
            "ip",
            "keyword",
            "numeric",
            "range"
          ]
        },
        "variable_width_histogram" : {
          "types" : [
            "numeric"
          ]
        },
        "weighted_avg" : {
          "types" : [
            "numeric"
          ]
        }
      }
    }
  }
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
