# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

1) В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
2) Какой алгоритм выбора лидера используется в Docker Swarm кластере?
3) Что такое Overlay Network?

### Ответ:

1) Global режим запускает контейнер на каждой из compute нод. Replcation режим запускает сторогое количество реплик контейнеров на compute нодах (причем контейнеры могут находится на одной ноде).
2) Алгоритм RAFT (крайне понятное обьяснение алгоритма http://thesecretlivesofdata.com/raft/).
3) Overlay-сеть создает подсеть, которую могут использовать контейнеры в разных физичесикх хостах swarm-кластера.  Overlay-сеть использует технологию vxlan, которая инкапсулирует layer 2 фреймы в layer 4 пакеты (UDP/IP). 

## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

### Ответ:

Прописываем ключи облака Яндекс: 

```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-05-docker-swarm/src/terraform$ cat variables.tf
# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b2gekc4vbv7jejkjhfm9"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b2gtp2cog4lf9jgalt0p"
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "centos-7-base" {
  default = "fe8cp9oofb7nmn29jfcp"
}

```

Выполняем terrfaorm init, plan и apply (незабываем в плейбуке ансибл сменить package на name, см. предыдущее домашнее задание):
```

dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-05-docker-swarm/src/terraform$ terraform apply

[...]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_node01 = "51.250.9.136"
external_ip_address_node02 = "62.84.127.82"
external_ip_address_node03 = "51.250.7.114"
external_ip_address_node04 = "51.250.10.32"
external_ip_address_node05 = "51.250.3.78"
external_ip_address_node06 = "62.84.115.202"
internal_ip_address_node01 = "192.168.101.11"
internal_ip_address_node02 = "192.168.101.12"
internal_ip_address_node03 = "192.168.101.13"
internal_ip_address_node04 = "192.168.101.14"
internal_ip_address_node05 = "192.168.101.15"
internal_ip_address_node06 = "192.168.101.16"

[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
tgvoe9yqi6j59pnnz7eb8nqd3 *   node01.netology.yc   Ready     Active         Leader           20.10.12
udt83q5k8u8wdg4zwgem001q7     node02.netology.yc   Ready     Active         Reachable        20.10.12
kvaq2xzflvzixkbcbiktfuks7     node03.netology.yc   Ready     Active         Reachable        20.10.12
6qo0ef7i634fobx9x2zcz99ra     node04.netology.yc   Ready     Active                          20.10.12
icm6fk805cucx1bejhb4ioxuu     node05.netology.yc   Ready     Active                          20.10.12
xsxa3r1327cu8ru0m7cvzy216     node06.netology.yc   Ready     Active                          20.10.12

```
Выполняем ifconfig для проверки наличия интерфейса в overlay сети:

```
[centos@node01 ~]$ ifconfig
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:db:0e:50:30  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

docker_gwbridge: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.18.0.1  netmask 255.255.0.0  broadcast 172.18.255.255
        inet6 fe80::42:cdff:fe47:430b  prefixlen 64  scopeid 0x20<link>
        ether 02:42:cd:47:43:0b  txqueuelen 0  (Ethernet)
        RX packets 70  bytes 6048 (5.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 70  bytes 6048 (5.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.101.11  netmask 255.255.255.0  broadcast 192.168.101.255
        inet6 fe80::d20d:1dff:fe55:45f8  prefixlen 64  scopeid 0x20<link>
        ether d0:0d:1d:55:45:f8  txqueuelen 100000  (Ethernet)
        RX packets 38237  bytes 202806460 (193.4 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 31303  bytes 4554369 (4.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

### Ответ:
```
[centos@node01 ~]$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
iribnhl9vu6x   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
1prlzbgpcjhe   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
b2mno20e2vcn   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
s3ok1ud0qu9j   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
qbp39ao5s5h9   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
pmmplqlnsm3a   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
lfemd0drbcwg   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
94brtjz1q9fk   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```

## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/

### Ответ:
После перезагрузки будет включено TLS шифрование в обмене (RAFT) между менеджерами.

```
[centos@node01 ~]$ sudo docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-aSpr9688RBPhzIqcQHI+mu003N2M6r5nv/ZsDsr9+0M

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```
