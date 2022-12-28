# Домашнее задание к занятию "15.1. Организация сети"

Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако и дополнительной части в AWS по желанию. Все домашние задания в 15 блоке связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
Все задания требуется выполнить с помощью Terraform, результатом выполненного домашнего задания будет код в репозитории. 

Перед началом работ следует настроить доступ до облачных ресурсов из Terraform используя материалы прошлых лекций и [ДЗ](https://github.com/netology-code/virt-homeworks/tree/master/07-terraform-02-syntax ). А также заранее выбрать регион (в случае AWS) и зону.

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)

1. Создать VPC.
- Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 192.168.10.0/24.
- Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1
- Создать в этой публичной подсети виртуалку с публичным IP и подключиться к ней, убедиться что есть доступ к интернету.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 192.168.20.0/24.
- Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс
- Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее и убедиться что есть доступ к интернету

Resource terraform для ЯО
- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet)
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table)
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance)

## Подготовка к заданию

Установка terraform:
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```
Проверяем ключ:
```
dgolodnikov@pve-vm1:~$  gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
gpg: directory '/home/dgolodnikov/.gnupg' created
gpg: /home/dgolodnikov/.gnupg/trustdb.gpg: trustdb created
/usr/share/keyrings/hashicorp-archive-keyring.gpg
-------------------------------------------------
pub   rsa4096 2020-05-07 [SC]
      E8A0 32E0 94D8 EB4E A189  D270 DA41 8C88 A321 9F7B
uid           [ unknown] HashiCorp Security (HashiCorp Package Signing) <security+packaging@hashicorp.com>
sub   rsa4096 2020-05-07 [E]
```

Устанавливаем:
```
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.lis
sudo apt update
sudo apt-get install terraform
```

Проверяем версию:
```
dgolodnikov@pve-vm1:~/REPO$ terraform version
Terraform v1.3.5
on linux_amd64
```

Также желательна установка облачного клиента cli Яндекс yc:
```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

Аутентификация сделаем  интерактивно через:
```
yc init 
```

Проверка, как все прошло:
```
dgolodnikov@pve-vm1:~$ yc config list
token: AQAAXXXXXXXXXXXXXXXXXXXXXGu-Kg
cloud-id: b1gXXXXXXXXXXXXXXXXhfm9
folder-id: b1gXXXXXXXXXXXXXlt0p
compute-default-zone: ru-central1-a
```

Полезные команды для мониторинга "что происходит":
```
dgolodnikov@pve-vm1:~$ yc vpc network list
+----+------+
| ID | NAME |
+----+------+
+----+------+
dgolodnikov@pve-vm1:~$ yc vpc subnet list
+----+------+------------+----------------+------+-------+
| ID | NAME | NETWORK ID | ROUTE TABLE ID | ZONE | RANGE |
+----+------+------------+----------------+------+-------+
+----+------+------------+----------------+------+-------+

dgolodnikov@pve-vm1:~$ yc vpc address list
+----+------+---------+----------+------+
| ID | NAME | ADDRESS | RESERVED | USED |
+----+------+---------+----------+------+
+----+------+---------+----------+------+

dgolodnikov@pve-vm1:~$ yc vpc gateway list
+----+------+-------------+
| ID | NAME | DESCRIPTION |
+----+------+-------------+
+----+------+-------------+
```
## Ответ:

Создадим манифесты терраформ, разделим на группы:
- [main.tf](terraform/10-main.tf) c данными для подключения
- [vpc.tf](terraform/20-vpc.tf) c конфигурацией сетей, подсетей 
- [route.tf](terraform/24-route.tf) c конфигурацией маршрутизации
- [compute.tf](terraform/30-сompute.tf) с конфигурацией VM
- [output.tf](terraform/90-output.tf) для определения выходных переменных
- [variables.tf](terraform/95-variables.tf) для определения входных переменных
- [meta.txt](terraform/96-meta.txt) данные для подключения (ключи).

Применим манифест (вывод сокращен):
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/15-cloud-01-network$ terraform -chdir=terraform apply -auto-approve 

...
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

...

yandex_vpc_network.vpc-netology: Creating...
yandex_vpc_network.vpc-netology: Creation complete after 2s [id=enp82iqgsrjpn3k8vv7c]
yandex_vpc_route_table.to-inet: Creating...
yandex_vpc_subnet.subnet-01: Creating...
yandex_vpc_subnet.subnet-01: Creation complete after 0s [id=e9bssh8f1mv7b88im1a4]
yandex_compute_instance.vm-2: Creating...
yandex_compute_instance.vm-1: Creating...
yandex_vpc_route_table.to-inet: Creation complete after 1s [id=enplpvg55h65v6dqojta]
yandex_vpc_subnet.subnet-02: Creating...
yandex_vpc_subnet.subnet-02: Creation complete after 1s [id=e9b6609dhn9jh8dekdrd]
yandex_compute_instance.vm-3: Creating...
yandex_compute_instance.vm-2: Still creating... [10s elapsed]
yandex_compute_instance.vm-1: Still creating... [10s elapsed]
yandex_compute_instance.vm-3: Still creating... [10s elapsed]
yandex_compute_instance.vm-2: Still creating... [20s elapsed]
yandex_compute_instance.vm-1: Still creating... [20s elapsed]
yandex_compute_instance.vm-3: Still creating... [20s elapsed]
yandex_compute_instance.vm-2: Still creating... [30s elapsed]
yandex_compute_instance.vm-1: Still creating... [30s elapsed]
yandex_compute_instance.vm-3: Still creating... [30s elapsed]
yandex_compute_instance.vm-3: Creation complete after 34s [id=fhm92trq9tj149icvdh0]
yandex_compute_instance.vm-1: Still creating... [40s elapsed]
yandex_compute_instance.vm-2: Still creating... [40s elapsed]
yandex_compute_instance.vm-2: Creation complete after 41s [id=fhmtqhm0uoarq40kvj8b]
yandex_compute_instance.vm-1: Still creating... [50s elapsed]
yandex_compute_instance.vm-1: Still creating... [1m0s elapsed]
yandex_compute_instance.vm-1: Still creating... [1m10s elapsed]
yandex_compute_instance.vm-1: Still creating... [1m20s elapsed]
yandex_compute_instance.vm-1: Creation complete after 1m25s [id=fhma995qpoqo45ci2ugf]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_NAT-instance = "130.193.51.32"
external_ip_address_VM-public = "158.160.54.206"
internal_ip_address_NAT-instance = "192.168.10.254"
internal_ip_address_VM-private = "192.168.20.5"
internal_ip_address_VM-public = "192.168.10.8"
subnet-01_vpc = "e9bssh8f1mv7b88im1a4"
subnet-02_vpc = "e9b6609dhn9jh8dekdrd"
vpc-netology = "enp82iqgsrjpn3k8vv7c"
```

Проверим утилитой yc:
```
dgolodnikov@pve-vm1:~$ yc vpc network list
+----------------------+---------------+
|          ID          |     NAME      |
+----------------------+---------------+
| enp82iqgsrjpn3k8vv7c | netology-test |
+----------------------+---------------+

dgolodnikov@pve-vm1:~$ yc vpc subnet list
+----------------------+-------------------+----------------------+----------------------+---------------+-------------------+
|          ID          |       NAME        |      NETWORK ID      |    ROUTE TABLE ID    |     ZONE      |       RANGE       |
+----------------------+-------------------+----------------------+----------------------+---------------+-------------------+
| e9b6609dhn9jh8dekdrd | private-subnet-02 | enp82iqgsrjpn3k8vv7c | enplpvg55h65v6dqojta | ru-central1-a | [192.168.20.0/24] |
| e9bssh8f1mv7b88im1a4 | public-subnet-01  | enp82iqgsrjpn3k8vv7c |                      | ru-central1-a | [192.168.10.0/24] |
+----------------------+-------------------+----------------------+----------------------+---------------+-------------------+

dgolodnikov@pve-vm1:~$ yc vpc address list
+----------------------+------+----------------+----------+------+
|          ID          | NAME |    ADDRESS     | RESERVED | USED |
+----------------------+------+----------------+----------+------+
| e9b8vc9p1tsivqif6l2i |      | 130.193.51.32  | false    | true |
| e9buv9rtfe19e9djboii |      | 158.160.54.206 | false    | true |
+----------------------+------+----------------+----------+------+
```

В итоге у нас были созданы 3 ВМ машины с адресами:
```
external_ip_address_NAT-instance = "130.193.51.32"
external_ip_address_VM-public = "158.160.54.206"
internal_ip_address_NAT-instance = "192.168.10.254"
internal_ip_address_VM-private = "192.168.20.5"
internal_ip_address_VM-public = "192.168.10.8"
```

Зайдем на VM-public и проверим доступ в интернет:
```
dgolodnikov@pve-vm1:~$ ssh 158.160.54.206

Last login: Wed Dec 28 08:38:11 2022 from 94.180.116.137
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

dgolodnikov@fhmtqhm0uoarq40kvj8b:~$ ping ngs.ru
PING ngs.ru (195.19.220.25) 56(84) bytes of data.
64 bytes from 195.19.220.25 (195.19.220.25): icmp_seq=1 ttl=59 time=47.3 ms
64 bytes from 195.19.220.25 (195.19.220.25): icmp_seq=2 ttl=59 time=47.0 ms
^C
--- ngs.ru ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 46.990/47.146/47.302/0.156 ms

dgolodnikov@fhmtqhm0uoarq40kvj8b:~$ curl ifconfig.me
158.160.54.206
```

Зайдем на VM-private c VM-public(предварительно скопирован SSH private ключ на VM-public) и проверим доступ в интернет:
```
dgolodnikov@fhmtqhm0uoarq40kvj8b:~$ ssh 192.168.20.5

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

dgolodnikov@fhm92trq9tj149icvdh0:~$ ping ngs.ru
PING ngs.ru (195.19.220.25) 56(84) bytes of data.
64 bytes from 195.19.220.25 (195.19.220.25): icmp_seq=1 ttl=57 time=58.9 ms
^C
--- ngs.ru ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 58.918/58.918/58.918/0.000 ms

dgolodnikov@fhm92trq9tj149icvdh0:~$ curl ifconfig.me
130.193.51.32
```
Доступ в Интернет есть. IP адрес в выводе `curl ifconfig.me` на VM-private соответсвует внешнему адресу VM nat-instance, что говорит о корректном маршруте прохождения трафика в сеть Интернет и рабочем NAT-instance. Все ок, задача выполнена. 

---
## Задание 2*. AWS (необязательное к выполнению)

1. Создать VPC.
- Cоздать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 10.10.1.0/24
- Разрешить в данной subnet присвоение public IP по-умолчанию. 
- Создать Internet gateway 
- Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
- Создать security group с разрешающими правилами на SSH и ICMP. Привязать данную security-group на все создаваемые в данном ДЗ виртуалки
- Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться что есть доступ к интернету.
- Добавить NAT gateway в public subnet.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 10.10.2.0/24
- Создать отдельную таблицу маршрутизации и привязать ее к private-подсети
- Добавить Route, направляющий весь исходящий трафик private сети в NAT.
- Создать виртуалку в приватной сети.
- Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети и убедиться, что с виртуалки есть выход в интернет.

Resource terraform
- [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
- [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

## Ответ

К сожалению нет доступа на AWS. Процедура получения аккаунта на AWS в процессе...