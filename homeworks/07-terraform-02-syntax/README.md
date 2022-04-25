# Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Terraform."

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services) или Yandex.Cloud.
Идеально будет познакомится с обоими облаками, потому что они отличаются. 

## Задача 1 (вариант с AWS). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов. 

AWS предоставляет достаточно много бесплатных ресурсов в первый год после регистрации, подробно описано [здесь](https://aws.amazon.com/free/).
1. Создайте аккаут aws.
1. Установите c aws-cli https://aws.amazon.com/cli/.
1. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
1. Создайте IAM политику для терраформа c правами
    * AmazonEC2FullAccess
    * AmazonS3FullAccess
    * AmazonDynamoDBFullAccess
    * AmazonRDSFullAccess
    * CloudWatchFullAccess
    * IAMFullAccess
1. Добавьте переменные окружения 
    ```
    export AWS_ACCESS_KEY_ID=(your access key id)
    export AWS_SECRET_ACCESS_KEY=(your secret access key)
    ```
1. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс. 

В виде результата задания приложите вывод команды `aws configure list`.

## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта. 
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы 
не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

### Ответ (для Яндекс Cloud)

Токен и Cloud id берется их переменных окружения (значения изменены). 
```
export TF_VAR_yc_token=afgafgaasfgadgagafdgasfdgsafgafg-Kg 
export TF_VAR_yc_cloud_id=afdgafsdgadfgasfdgaf
или 
export TF_VAR_yc_token=`yc config list | grep token | awk '{print $2}'`
export TF_VAR_yc_cloud_id=`yc config list | grep cloud_id | awk '{print $2}'`
```
Конфиг файлы ниже:
https://github.com/AirDRoN-lab/devops-netology/tree/main/terraform/YandexC_backup

Доступные образы в YaCloud:
```
yc compute image list --folder-id standard-images
```

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер 
   1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
   блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион 
   внутри блока `provider`.
   2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти 
   [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс 
   1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
   Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
   `Example Usage`, но желательно, указать большее количество параметров.
   2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 

В качестве результата задания предоставьте:
1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
1. Ссылку на репозиторий с исходной конфигурацией терраформа.  

### Ответ (для Яндекс Cloud)

   Для создания собственного образа (не только ami) можно использовать Packer от HashiCorp. В домашнем задании используеется один из штатных обланчных образов.
   
   Конфигурация терраформа приведена по ссылке:
 https://github.com/AirDRoN-lab/devops-netology/tree/main/terraform/YandexC_backup
 
   В outputs.tf поместил данные по IP адресации, зоне, дате создания VM и идентификаторы сети и подсети.
 
   Результат выполнения terraform apply:

```
vagrant@server1:~/devops-netology/terraform$ terraform apply
yandex_vpc_network.network-1: Creating...
yandex_vpc_network.network-1: Creation complete after 3s [id=enp1h7sdftf97t7rlm17]
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_subnet.subnet-1: Creation complete after 1s [id=e9buu8ssdfth5oeqqk1k]
yandex_compute_instance.vm-1: Creating...
yandex_compute_instance.vm-1: Still creating... [10s elapsed]
yandex_compute_instance.vm-1: Still creating... [20s elapsed]
yandex_compute_instance.vm-1: Still creating... [30s elapsed]
yandex_compute_instance.vm-1: Still creating... [40s elapsed]
yandex_compute_instance.vm-1: Still creating... [50s elapsed]
yandex_compute_instance.vm-1: Still creating... [1m0s elapsed]
yandex_compute_instance.vm-1: Still creating... [1m10s elapsed]
yandex_compute_instance.vm-1: Still creating... [1m20s elapsed]
yandex_compute_instance.vm-1: Still creating... [1m30s elapsed]
yandex_compute_instance.vm-1: Creation complete after 1m32s [id=fhmc7phjjsldsfttp6p4m]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

created_at_vm_1 = "2022-04-21T05:46:21Z"
external_ip_address_vm_1 = "51.250.83.0"
internal_ip_address_vm_1 = "192.168.250.6"
network_vm_1 = "enpmabmvk51ma71qcm5a"
subnet_vm_1 = "e9bd0gj2in2vhfgib3d0"
zone = "ru-central1-a"

```
SSH доступ есть:
```
vagrant@server1:~/devops-netology/terraform$ ssh 51.250.83.0
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

vagrant@fhmdvq6skoqrgjv5m35h:~$ 

```
Описание созданной инфраструктуры (в yaml):
```
vagrant@server1:~/devops-netology/terraform$   yc compute instance list --format=yaml
- id: fhmg8vjds9omer0m4ujk
  folder_id: b1gtp2cog4lf9jgalt0p
  created_at: "2022-04-21T05:46:21Z"
  name: terraform
  zone_id: ru-central1-a
  platform_id: standard-v1
  resources:
    memory: "2147483648"
    cores: "2"
    core_fraction: "100"
  status: RUNNING
  boot_disk:
    mode: READ_WRITE
    device_name: fhmdvq6skoqrgjv5m35h
    auto_delete: true
    disk_id: fhmdvq6skoqrgjv5m35h
  network_interfaces:
  - index: "0"
    mac_address: d0:0d:10:47:e6:de
    subnet_id: e9bd0gj2in2vhfgib3d0
    primary_v4_address:
      address: 192.168.250.6
      one_to_one_nat:
        address: 51.250.83.0
        ip_version: IPV4
  fqdn: fhmg8vjds9omer0m4ujk.auto.internal
  scheduling_policy: {}
  network_settings:
    type: STANDARD
  placement_policy: {}
```
PS: AWS облаков в процессе получения. Возможно домашка будет дорабаота в части работы с AWS =)

### Ответ (кратко для AWS обе задачи)

Установка AWS (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

```
$ curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Присвоение ключей (ключи изменены):
```
$ export AWS_ACCESS_KEY_ID=AXXXXXXXXXXXXXXDSPIMQ2
$ export AWS_SECRET_ACCESS_KEY=/QXXXXXXXXXXXXXXXXXXXXXXXXXXXPQlP/D

vagrant@server1:~/.aws$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                  default              env    ['AWS_PROFILE', 'AWS_DEFAULT_PROFILE']
access_key     ****************IMQ2              env
secret_key     ****************lP/D              env
    region                us-east-1      config-file    ~/.aws/config

```
Конфиг файлы для AWS ниже:
https://github.com/AirDRoN-lab/devops-netology/tree/main/terraform/AWS_backup

Вывод terraform output:

```
vagrant@server1:~/devops-netology/terraform$ terraform refresh
aws_instance.netolo: Refreshing state... [id=i-0dd30ccf6d497186b]

Outputs:

AZ_names = tolist([
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
  "us-east-1d",
  "us-east-1e",
  "us-east-1f",
])
account_id = "297667789469"
image_id = "ami-0c4f7023847b90238"
instance_core = 1
instance_ip_addr = "172.31.16.174"
instance_ip_public_addr = "18.208.248.207"
regions_id = "aws"
regions_names = toset([
  "ap-northeast-1",
  "ap-northeast-2",
  "ap-northeast-3",
  "ap-south-1",
  "ap-southeast-1",
  "ap-southeast-2",
  "ca-central-1",
  "eu-central-1",
  "eu-north-1",
  "eu-west-1",
  "eu-west-2",
  "eu-west-3",
  "sa-east-1",
  "us-east-1",
  "us-east-2",
  "us-west-1",
  "us-west-2",
])
subnet_id = "subnet-0233fe9108df5be14"
```
