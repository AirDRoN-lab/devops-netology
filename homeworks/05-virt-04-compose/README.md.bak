# Домашнее задание к занятию "5.4. Оркестрация группой Docker контейнеров на примере Docker Compose"

## Задача 1

Создать собственный образ операционной системы с помощью Packer.

Для получения зачета, вам необходимо предоставить:
- Скриншот страницы, как на слайде из презентации (слайд 37).

### Ответ:

Создаем VPC через CLI yc (установка yc https://cloud.yandex.ru/docs/cli/operations/install-cli):

```
dgolodnikov@DESKTOP-V4JG0DR:~$ yc init
Welcome! This command will take you through the configuration process.
Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb in order to obtain OAuth token.

Please enter OAuth token: AQXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXKg
You have one cloud available: 'cloud-bgp' (id = bXXXXXXXXXXXXXXXXXX9). It is going to be used by default.
Please choose folder to use:
 [1] default (id = bXXXXXXXXXXXXXXXXXX0)
 [2] Create a new folder
Please enter your numeric choice: 2
Please enter a folder name: netology
Your current folder has been set to 'netology' (id = bXXXXXXXXXXXXXXXXXXp).
Do you want to configure a default Compute zone? [Y/n] y
Which zone do you want to use as a profile default?
 [1] ru-central1-a
 [2] ru-central1-b
 [3] ru-central1-c
 [4] Don't set default zone
Please enter your numeric choice: 1
Your profile default Compute zone has been set to 'ru-central1-a'.

dgolodnikov@DESKTOP-V4JG0DR:~$ yc config list
token: AQXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXKg
cloud-id: bXXXXXXXXXXXXXXXXXX9
folder-id: bXXXXXXXXXXXXXXXXXXp
compute-default-zone: ru-central1-a

dgolodnikov@DESKTOP-V4JG0DR:~$ yc vpc network create --name net --labels my-label=netology --description "my firstest network via yc"
id: enp64mficchuphspl4rs
folder_id: bXXXXXXXXXXXXXXXXXXp
created_at: "2022-02-15T18:10:16Z"
name: net
description: my firstest network via yc
labels:
  my-label: netology
  
dgolodnikov@DESKTOP-V4JG0DR:~$ yc vpc subnet create --name my-subnet-a --zone ru-central1-a --range 10.1.2.0/24 --network-name net --description "my firstest subnet via yc"
id: e9br1ltsar0io63ndh6v
folder_id: bXXXXXXXXXXXXXXXXXXp
created_at: "2022-02-15T18:13:32Z"
name: my-subnet-a
description: my firstest subnet via yc
network_id: enp64mficchuphspl4rs
zone_id: ru-central1-a
v4_cidr_blocks:
- 10.1.2.0/24
```

Установка Packer:

```
dgolodnikov@DESKTOP-V4JG0DR:~$ sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
dgolodnikov@DESKTOP-V4JG0DR:~$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
dgolodnikov@DESKTOP-V4JG0DR:~$ sudo apt-get update && sudo apt-get install packer
dgolodnikov@DESKTOP-V4JG0DR:~$ packer --version
1.7.10
```

Сборка образа:

```
dgolodnikov@DESKTOP-V4JG0DR:~$ packer validate centos7-base.json
The configuration is valid.
dgolodnikov@DESKTOP-V4JG0DR:~$ packer build centos7-base.json
yandex: output will be in this color.

==> yandex: Creating temporary RSA SSH key for instance...
==> yandex: Using as source image: fd82n2d2h9fet9648lej (name: "centos-7-v20220214", family: "centos-7")
==> yandex: Use provided subnet id e9br1ltsar0io63ndh6v
==> yandex: Creating disk...
==> yandex: Creating instance...
==> yandex: Waiting for instance with id fhmiplaaqasbej12hi30 to become active...
    yandex: Detected instance IP: 84.201.158.104
==> yandex: Using SSH communicator to connect: 84.201.158.104
[...]
==> yandex: Destroying boot disk...
    yandex: Disk has been deleted!
Build 'yandex' finished after 3 minutes 24 seconds.

==> Wait completed after 3 minutes 24 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: centos-7-base (id: fd8cp9oofb7nmn29jfcp) with family name centos
```

Образ готов (скриншот в папке Screen):
```
dgolodnikov@DESKTOP-V4JG0DR:~$ yc compute image list
+----------------------+---------------+--------+----------------------+--------+
|          ID          |     NAME      | FAMILY |     PRODUCT IDS      | STATUS |
+----------------------+---------------+--------+----------------------+--------+
| fd8cp9oofb7nmn29jfcp | centos-7-base | centos | f2epin40q8nh7fqdv3sh | READY  |
+----------------------+---------------+--------+----------------------+--------+

```
<p align="center">
  <img width="1200" height="600" src="./screen/image_ready.png">
</p>

## Задача 2

Создать вашу первую виртуальную машину в Яндекс.Облаке.

Для получения зачета, вам необходимо предоставить:
- Скриншот страницы свойств созданной ВМ, как на примере ниже:

### Ответ:

Установка Terraform
```
dgolodnikov@DESKTOP-V4JG0DR:~$ sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
dgolodnikov@DESKTOP-V4JG0DR:~$ sudo apt install terraform
dgolodnikov@DESKTOP-V4JG0DR:~$ terraform --version
Terraform v1.1.5
on linux_amd64
```
Создаем сервисный аккаунт через web, генерируем ключ key.json для авторизации. Проводим реинициализацию аккаунта.

```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ yc iam key create --service-account-name my-robot -o key.json
id: ajede87b2su18t8eb70r
service_account_id: ajehjb1joqfm8em5vndr
created_at: "2022-02-16T04:31:52.896141883Z"
key_algorithm: RSA_2048
```
Проводим подготовку конфигурационный файлов, в нашем случае см. ниже (корректировал только variables.tf):

```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ ll
total 12
drwxr-xr-x 1 dgolodnikov dgolodnikov  512 Feb 16 11:31 ./
drwxr-xr-x 1 dgolodnikov dgolodnikov  512 Feb 16 01:57 ../
-rw------- 1 dgolodnikov dgolodnikov 2402 Feb 16 11:31 key.json
-rw-r--r-- 1 dgolodnikov dgolodnikov  260 Feb 16 01:57 network.tf
-rw-r--r-- 1 dgolodnikov dgolodnikov  628 Feb 16 01:57 node01.tf
-rw-r--r-- 1 dgolodnikov dgolodnikov  265 Feb 16 01:57 output.tf
-rw-r--r-- 1 dgolodnikov dgolodnikov  252 Feb 16 01:57 provider.tf
-rw-r--r-- 1 dgolodnikov dgolodnikov  560 Feb 16 11:03 variables.tf

```
Проводим инициализацию terrform и тестируем (plan):
```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.71.0...
- Installed yandex-cloud/yandex v0.71.0 (self-signed, key ID E40F590B50BB8E40)
...

Terraform has been successfully initialized!

dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.node01 will be created
  + resource "yandex_compute_instance" "node01" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node01.netology.cloud"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                centos:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcGllXOZh1rEQngHA1EiUDvuFlIG9JsBRwanH7ABP77mVqQanURIeYs1vC8WL0wzLlNGcAscn6+J/im33pxMZShIlnCQRNkz76q5y9GniMTvXUt501q3n4ZpaSC68SoK8FcWBkLW1VAl1Y57Ol0iRhaZA2AYH6Z1PTfCT4FiBRWuhLSWVmzYYg7ibziZGbW9W9wdBn+eoIayKIZ+TstommzLrNeiMBveF5u5EQso/jITdgIbBBU8gsj9af7Q4Mhu61NnDcmypcAGFE3DvVTMJEH9e+ArnYhSQS37h4sM0eRD7p6cjZRW7yjj4IG2w+aMbikpF/rdw+cRRlsqjmOvQKVO+yN7cQan2BRZIHhHLZKMrQO25U5xw2GX7mOJBt9EHSOAEcfiPR41ZNBi6B5IOWz2DVKL8qVC+ufNApIerdROSlP/sYqt/nWe9ch2qTmrbwS+Fvb9LfAT6D8ZCjE60b33I3DqBrbYH1ZkMlbOHmXHj7G6gjNDjdcAsveKwMgaU= dgolodnikov@DESKTOP-V4JG0DR
            EOT
        }
      + name                      = "node01"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8cp9oofb7nmn29jfcp"
              + name        = "root-node01"
              + size        = 50
              + snapshot_id = (known after apply)
              + type        = "network-nvme"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 8
          + memory        = 8
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.default will be created
  + resource "yandex_vpc_subnet" "default" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.101.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_node01_yandex_cloud = (known after apply)
  + internal_ip_address_node01_yandex_cloud = (known after apply)
```

Удаляем ранее созданую (в задаче 1 через yc) сеть и подсеть:
```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ yc vpc subnet delete --name my-subnet-a
done (2s)
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ yc vpc net delete --name net
```

Создаем VM:

```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ terraform apply
[...]
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.default: Creating...
yandex_vpc_network.default: Creation complete after 2s [id=enpglq5q1uclqicj5ot9]
yandex_vpc_subnet.default: Creating...
yandex_vpc_subnet.default: Creation complete after 1s [id=e9buf55cskv9ogar7emh]
yandex_compute_instance.node01: Creating...
yandex_compute_instance.node01: Still creating... [10s elapsed]
yandex_compute_instance.node01: Still creating... [20s elapsed]
yandex_compute_instance.node01: Creation complete after 29s [id=fhmt1pu30mfjajeqes6o]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_node01_yandex_cloud = "62.84.124.71"
internal_ip_address_node01_yandex_cloud = "192.168.101.24"
```

Созданная VM ниже:

```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ yc compute instance list
+----------------------+--------+---------------+---------+--------------+----------------+
|          ID          |  NAME  |    ZONE ID    | STATUS  | EXTERNAL IP  |  INTERNAL IP   |
+----------------------+--------+---------------+---------+--------------+----------------+
| fhmtvqn5pvqrbdr44aad | node01 | ru-central1-a | RUNNING | 62.84.124.71 | 192.168.101.24 |
+----------------------+--------+---------------+---------+--------------+----------------+

```

<p align="center">
  <img width="1200" height="600" src="./screen/vm_ready.png">
</p>

Удаление VM:

```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/terraform$ terraform destroy
[...]
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

yandex_compute_instance.node01: Destroying... [id=fhmtvqn5pvqrbdr44aad]
yandex_compute_instance.node01: Still destroying... [id=fhmtvqn5pvqrbdr44aad, 10s elapsed]
yandex_compute_instance.node01: Destruction complete after 12s
yandex_vpc_subnet.default: Destroying... [id=e9btlsaccubsfh55ntk0]
yandex_vpc_subnet.default: Destruction complete after 3s
yandex_vpc_network.default: Destroying... [id=enpmnufjjmd2uqej39u9]
yandex_vpc_network.default: Destruction complete after 1s

Destroy complete! Resources: 3 destroyed.
```

## Задача 3

Создать ваш первый готовый к боевой эксплуатации компонент мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить:
- Скриншот работающего веб-интерфейса Grafana с текущими метриками, как на примере ниже

### Ответ:

Для выполнения задания необходимо исправить файл provision.yml, а именно package, заменить на name. В противном случае вылетает ошибка:
```
TASK [Installing tools] ************************************************************************************************************************************************
failed: [node01.netology.cloud] (item=git) => {"ansible_loop_var": "item", "changed": false, "item": "git", "msg": "Unsupported parameters for (ansible.legacy.yum) module: package. Supported parameters include: lock_timeout, disable_excludes, exclude, allow_downgrade, disable_gpg_check, conf_file, use_backend, validate_certs, state, disablerepo, releasever, skip_broken, cacheonly, autoremove, download_dir, name (pkg), installroot, install_weak_deps, update_cache (expire-cache), download_only, bugfix, list, install_repoquery, update_only, disable_plugin, enablerepo, security, enable_plugin."}
failed: [node01.netology.cloud] (item=curl) => {"ansible_loop_var": "item", "changed": false, "item": "curl", "msg": "Unsupported parameters for (ansible.legacy.yum) module: package. Supported parameters include: lock_timeout, disable_excludes, exclude, allow_downgrade, disable_gpg_check, conf_file, use_backend, validate_certs, state, disablerepo, releasever, skip_broken, cacheonly, autoremove, download_dir, name (pkg), installroot, install_weak_deps, update_cache (expire-cache), download_only, bugfix, list, install_repoquery, update_only, disable_plugin, enablerepo, security, enable_plugin."}
```

Выполняем замену IP адреса в файле inventory и запускаем playbook.

```
dgolodnikov@DESKTOP-V4JG0DR:~/neto_hw01/virt-homeworks/05-virt-04-docker-compose/src/ansible$ ansible-playbook provision.yml

PLAY [nodes] ***********************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************
ok: [node01.netology.cloud]

...

PLAY RECAP *************************************************************************************************************************************************************
node01.netology.cloud      : ok=12   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Проверяем на самой ВМ запуск контейнеров:

```
[centos@node01 stack]$ sudo docker-compose ps
    Name                  Command                  State                                                   Ports
-------------------------------------------------------------------------------------------------------------------------------------------------------------
alertmanager   /bin/alertmanager --config ...   Up             9093/tcp
caddy          /sbin/tini -- caddy -agree ...   Up             0.0.0.0:3000->3000/tcp, 0.0.0.0:9090->9090/tcp, 0.0.0.0:9091->9091/tcp, 0.0.0.0:9093->9093/tcp
cadvisor       /usr/bin/cadvisor -logtostderr   Up (healthy)   8080/tcp
grafana        /run.sh                          Up             3000/tcp
nodeexporter   /bin/node_exporter --path. ...   Up             9100/tcp
prometheus     /bin/prometheus --config.f ...   Up             9090/tcp
pushgateway    /bin/pushgateway                 Up             9091/tcp
```

Лоигимся в систему управления на порт 3000:

<p align="center">
  <img width="1200" height="600" src="./screen/serv_ready1.png">
</p>
<p align="center">
  <img width="1200" height="600" src="./screen/serv_ready2.png">
</p>

## Задача 4 (*)

Создать вторую ВМ и подключить её к мониторингу развёрнутому на первом сервере.

Для получения зачета, вам необходимо предоставить:
- Скриншот из Grafana, на котором будут отображаться метрики добавленного вами сервера.

### Ответ:

Будет выполнена позже