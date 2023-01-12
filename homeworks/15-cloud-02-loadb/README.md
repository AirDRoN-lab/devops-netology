# Домашнее задание к занятию 15.2 "Вычислительные мощности. Балансировщики нагрузки".
Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако, и дополнительной части в AWS (можно выполнить по желанию). Все домашние задания в 15 блоке связаны друг с другом и в конце представляют пример законченной инфраструктуры.
Все задания требуется выполнить с помощью Terraform, результатом выполненного домашнего задания будет код в репозитории. Перед началом работ следует настроить доступ до облачных ресурсов из Terraform, используя материалы прошлых лекций и ДЗ.

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)

1. Создать bucket Object Storage и разместить там файл с картинкой:
- Создать bucket в Object Storage с произвольным именем (например, _имя_студента_дата_);
- Положить в bucket файл с картинкой;
- Сделать файл доступным из Интернет.
2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и web-страничкой, содержащей ссылку на картинку из bucket:
- Создать Instance Group с 3 ВМ и шаблоном LAMP. Для LAMP рекомендуется использовать `image_id = fd827b91d99psvq5fjit`;
- Для создания стартовой веб-страницы рекомендуется использовать раздел `user_data` в [meta_data](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata);
- Разместить в стартовой веб-странице шаблонной ВМ ссылку на картинку из bucket;
- Настроить проверку состояния ВМ.
3. Подключить группу к сетевому балансировщику:
- Создать сетевой балансировщик;
- Проверить работоспособность, удалив одну или несколько ВМ.
4. *Создать Application Load Balancer с использованием Instance group и проверкой состояния.

Документация
- [Compute instance group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance_group)
- [Network Load Balancer](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer)
- [Группа ВМ с сетевым балансировщиком](https://cloud.yandex.ru/docs/compute/operations/instance-groups/create-with-balancer)
---

## Ответ:

Начальное состояние Яндекс облака (далее yc):

```
dgolodnikov@pve-vm1:~/REPO$  yc vpc network list
+----+------+
| ID | NAME |
+----+------+
+----+------+

dgolodnikov@pve-vm1:~/REPO$  yc vpc subnet list
+----+------+------------+----------------+------+-------+
| ID | NAME | NETWORK ID | ROUTE TABLE ID | ZONE | RANGE |
+----+------+------------+----------------+------+-------+
+----+------+------------+----------------+------+-------+

dgolodnikov@pve-vm1:~/REPO$ yc vpc address list
+----+------+---------+----------+------+
| ID | NAME | ADDRESS | RESERVED | USED |
+----+------+---------+----------+------+
+----+------+---------+----------+------+

```
Создадим манифесты терраформ, разделим на группы:
- [10-main.tf](terraform/10-main.tf) c конфигурацией провайдера и требованиям к terraform
- [15-sa.tf](terraform/15-sa.tf) c конфигурацией сервисного аккаунта (создан единый аккаунт с ролью `editor`)
- [20-vpc.tf](terraform/20-vpc.tf) c конфигурацией VPC (сетей, подсетей)
- [26-storage.tf](terraform/26-storage.tf) c конфигурацией storage и обьекта (картинка terraform/pic/sigal.jpg)
- [30-compute.tf](terraform/30-сompute.tf) с конфигурацией Instanсe Group 
- [40-lb.tf](terraform/40-lb.tf) с конфигурацией сетевого LoadBalancer
- [90-output.tf](terraform/90-output.tf) для определения выходных переменных (для удобства)
- [95-variables.tf](terraform/95-variables.tf) для определения входных переменных облака
- [96-meta.txt](terraform/96-meta.txt) данные для подключения (ключи и скрипт для формирования заглавной страницы).

Применяем манифесты, запускаем terraform apply (вывод намеренно сокращен):
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/15-cloud-02-loadb$ terraform -chdir=terraform apply -auto-approve
...
Changes to Outputs:
  + lb-01      = []
  + network-01 = (known after apply)
  + subnet-01  = (known after apply)
time_sleep.wait_60_seconds: Creating...
yandex_vpc_network.vpc-netology: Creating...
yandex_iam_service_account.sa: Creating...
yandex_vpc_network.vpc-netology: Creation complete after 1s [id=enps4gaqbcp1h3e15bdi]
yandex_vpc_subnet.subnet-01: Creating...
yandex_iam_service_account.sa: Creation complete after 2s [id=aje21tgv9c54j01i7vsm]
yandex_resourcemanager_folder_iam_member.sa-editor: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creating...
yandex_vpc_subnet.subnet-01: Creation complete after 1s [id=e9b04ffjuc11k1vli4fm]
yandex_compute_instance_group.ig-01: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creation complete after 1s [id=aje0tj3flv4l3port4il]
yandex_storage_bucket.ya-bucket-001: Creating...
yandex_resourcemanager_folder_iam_member.sa-editor: Creation complete after 2s [id=b1gedruc3jl8tepos1sa/editor/serviceAccount:aje21tgv9c54j01i7vsm]
yandex_storage_bucket.ya-bucket-001: Creation complete after 1s [id=ya-bucket-001]
time_sleep.wait_60_seconds: Still creating... [10s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [10s elapsed]
time_sleep.wait_60_seconds: Still creating... [20s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [20s elapsed]
time_sleep.wait_60_seconds: Still creating... [30s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [30s elapsed]
time_sleep.wait_60_seconds: Still creating... [40s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [40s elapsed]
time_sleep.wait_60_seconds: Still creating... [50s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [50s elapsed]
time_sleep.wait_60_seconds: Still creating... [1m0s elapsed]
time_sleep.wait_60_seconds: Creation complete after 1m0s [id=2023-01-12T02:00:18Z]
yandex_storage_object.sigal: Creating...
yandex_storage_object.sigal: Creation complete after 0s [id=sigal.jpg]
yandex_compute_instance_group.ig-01: Still creating... [1m0s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [1m10s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [1m20s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [1m30s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [1m40s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [1m50s elapsed]
yandex_compute_instance_group.ig-01: Still creating... [2m0s elapsed]
yandex_compute_instance_group.ig-01: Creation complete after 2m8s [id=cl1s1f9g50t2uri83u40]
yandex_lb_network_load_balancer.lb-01: Creating...
yandex_lb_network_load_balancer.lb-01: Creation complete after 4s [id=enp3nkmvg9r4lofm281d]

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

lb-01 = tolist([])
network-01 = "enps4gaqbcp1h3e15bdi"
subnet-01 = "e9b04ffjuc11k1vli4fm"

```

Т.е. в итоге мы создали:

```
dgolodnikov@pve-vm1:~$ yc vpc network list
+----------------------+--------------+
|          ID          |     NAME     |
+----------------------+--------------+
| enps4gaqbcp1h3e15bdi | vpc-netology |
+----------------------+--------------+

dgolodnikov@pve-vm1:~$ yc vpc subnet list
+----------------------+-----------+----------------------+----------------+---------------+-------------------+
|          ID          |   NAME    |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |       RANGE       |
+----------------------+-----------+----------------------+----------------+---------------+-------------------+
| e9b04ffjuc11k1vli4fm | subnet-01 | enps4gaqbcp1h3e15bdi |                | ru-central1-a | [192.168.10.0/24] |
+----------------------+-----------+----------------------+----------------+---------------+-------------------+

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/15-cloud-02-loadb/screens$ yc compute instance-group list
+----------------------+-------+--------+------+
|          ID          | NAME  | STATUS | SIZE |
+----------------------+-------+--------+------+
| cl1s1f9g50t2uri83u40 | ig-01 | ACTIVE |    3 |
+----------------------+-------+--------+------+

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/15-cloud-02-loadb/screens$ yc lb network-load-balancer list
+----------------------+-------+-------------+----------+----------------+------------------------+--------+
|          ID          | NAME  |  REGION ID  |   TYPE   | LISTENER COUNT | ATTACHED TARGET GROUPS | STATUS |
+----------------------+-------+-------------+----------+----------------+------------------------+--------+
| enp3nkmvg9r4lofm281d | lb-01 | ru-central1 | EXTERNAL |              1 | enp5g3smpl30rh02lr01   | ACTIVE |
+----------------------+-------+-------------+----------+----------------+------------------------+--------+

dgolodnikov@pve-vm1:~$ yc load-balancer network-load-balancer show lb-01
id: enp3nkmvg9r4lofm281d
folder_id: b1gedruc3jl8tepos1sa
created_at: "2023-01-12T02:01:29Z"
name: lb-01
region_id: ru-central1
status: ACTIVE
type: EXTERNAL
listeners:
  - name: lb-ls-01
    address: 51.250.89.16
    port: "80"
    protocol: TCP
    target_port: "80"
    ip_version: IPV4
attached_target_groups:
  - target_group_id: enp5g3smpl30rh02lr01
    health_checks:
      - name: hc-http
        interval: 2s
        timeout: 1s
        unhealthy_threshold: "2"
        healthy_threshold: "2"
        http_options:
          port: "80"
          path: /

dgolodnikov@pve-vm1:~$ yc load-balancer target-group list
+----------------------+---------------------+---------------------+-------------+--------------+
|          ID          |        NAME         |       CREATED       |  REGION ID  | TARGET COUNT |
+----------------------+---------------------+---------------------+-------------+--------------+
| enp5g3smpl30rh02lr01 | lb-target-group-001 | 2023-01-12 01:59:27 | ru-central1 |            3 |
+----------------------+---------------------+---------------------+-------------+--------------+

dgolodnikov@pve-vm1:~$ yc storage bucket list
+---------------+----------------------+----------+-----------------------+---------------------+
|     NAME      |      FOLDER ID       | MAX SIZE | DEFAULT STORAGE CLASS |     CREATED AT      |
+---------------+----------------------+----------+-----------------------+---------------------+
| ya-bucket-001 | b1gedruc3jl8tepos1sa |        0 | STANDARD              | 2023-01-12 01:59:22 |
+---------------+----------------------+----------+-----------------------+---------------------+

dgolodnikov@pve-vm1:~$ yc storage bucket show ya-bucket-001
name: ya-bucket-001
folder_id: b1gedruc3jl8tepos1sa
anonymous_access_flags:
  read: true
  list: true
  config_read: true
default_storage_class: STANDARD
versioning: VERSIONING_DISABLED
created_at: "2023-01-12T01:59:22.038585Z"

```

- [01_yc_dashboard.PNG](screens/01_yc_dashboard.PNG) скрин дашборда yc с созданными сервисами

- [02_yc_sa.PNG](screens/02_yc_sa.PNG) скрин созданных сервисных аккаунтов. Создан единый аккаунт 'sa' с ролью `editor`.

- [03_yc_storage.PNG](screens/03_yc_storage.PNG) скрин созданного бакета с обьектом. Ссылка на обьект скопирована и вставлена в файл metadata [96-meta.txt](terraform/96-meta.txt). Также в данный файл добавлен скрипт для вывода мак адресов VM для того, чтобы тестовые страницы различались.

- [04_yc_vm.PNG](screens/04_yc_vm.PNG) скрин созданных VM с помощью instance group

- [05_yc_ig.PNG](screens/05_yc_ig.PNG) скрин созданной instance group, использованной для создания VM и поддержания сервиса

- [06_yc_lb.PNG](screens/06_yc_lb.PNG) скрин созданного балансироващика трафика с таргет группой с VM. Адрес балансировщика http://51.250.89.16/. 

Проверим как балансируется трафик между VM:

- [07_test_page_vm01.PNG](screens/07_test_page_vm01.PNG) 
- [08_test_page_vm02.PNG](screens/08_test_page_vm02.PNG) 
- [09_test_page_vm03.PNG](screens/09_test_page_vm03.PNG) 

Балансировка выполняется по всем трем VM! Это видно по различным стартовым страницам (различные mac адреса). Балансировка работает. Проверим поведение сервиса при удалении двух VM из трех . Инициируем удаление:

- [10_yc_vm_del.PNG](screens/10_yc_vm_del.PNG) 

VM автоматически пересоздаются и имеют новый id:

- [11_yc_vm_recreate.PNG](screens/11_yc_vm_recreate.PNG) 

Проверим именились ли целевые группы в настройках Loadbalancer:

- [12_yc_lb_afterdel.PNG](screens/12_yc_lb_afterdel.PNG) 

Целевая группа хостов изменилась, у VM новые id. 

```
dgolodnikov@pve-vm1:~$ yc compute instance list
+----------------------+---------------------------+---------------+---------+-------------+---------------+
|          ID          |           NAME            |    ZONE ID    | STATUS  | EXTERNAL IP |  INTERNAL IP  |
+----------------------+---------------------------+---------------+---------+-------------+---------------+
| fhm40e3kstpejq02os2d | cl1s1f9g50t2uri83u40-ohew | ru-central1-a | RUNNING |             | 192.168.10.7  |
| fhmdf036fria2vgbpmpp | cl1s1f9g50t2uri83u40-emyb | ru-central1-a | RUNNING |             | 192.168.10.9  |
| fhmkq7c1mgvn4ur9uas7 | cl1s1f9g50t2uri83u40-oxyz | ru-central1-a | RUNNING |             | 192.168.10.33 |
+----------------------+---------------------------+---------------+---------+-------------+---------------+
```

Повторно проверим балансировку.

- [13_test_page_vm01.PNG](screens/13_test_page_vm01.PNG) 
- [14_test_page_vm02.PNG](screens/14_test_page_vm02.PNG) 
- [15_test_page_vm03.PNG](screens/15_test_page_vm03.PNG) 

Балансировка работает. Видно изменение мак адреса на стартовых страницах, относительно скринотов в начале задания (до удаления VM). Задание выполнено!

PS: Задание со * (Application LoadBalancer) будет выполнено позже, после получение допуска к диплому (почему-то его нет =) ).

## Задание 2*. AWS (необязательное к выполнению)

Используя конфигурации, выполненные в рамках ДЗ на предыдущем занятии, добавить к Production like сети Autoscaling group из 3 EC2-инстансов с  автоматической установкой web-сервера в private домен.

1. Создать bucket S3 и разместить там файл с картинкой:
- Создать bucket в S3 с произвольным именем (например, _имя_студента_дата_);
- Положить в bucket файл с картинкой;
- Сделать доступным из Интернета.
2. Сделать Launch configurations с использованием bootstrap скрипта с созданием веб-странички на которой будет ссылка на картинку в S3. 
3. Загрузить 3 ЕС2-инстанса и настроить LB с помощью Autoscaling Group.

Resource terraform
- [S3 bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [Launch Template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)
- [Autoscaling group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)
- [Launch configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration)

Пример bootstrap-скрипта:
```
#!/bin/bash
yum install httpd -y
service httpd start
chkconfig httpd on
cd /var/www/html
echo "<html><h1>My cool web-server</h1></html>" > index.html
```

## Ответ:

Нет возможности сделать ДЗ, в связи с текущим отсутствием возможности создать тестовый аккаунт в AWS.