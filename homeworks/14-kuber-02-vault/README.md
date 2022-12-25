# Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

## Задача 1: Работа с модулем Vault

Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube

```
kubectl apply -f 14.2/vault-pod.yml
```

Получить значение внутреннего IP пода

```
kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
```

Примечание: jq - утилита для работы с JSON в командной строке

Запустить второй модуль для использования в качестве клиента

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Установить дополнительные пакеты

```
dnf -y install pip
pip install hvac
```

Запустить интепретатор Python и выполнить следующий код, предварительно
поменяв IP и токен

```
import hvac
client = hvac.Client(
    url='http://10.244.2.53:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!! In VAULT! '),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

## Ответ:

Выполнем команды согласно описания. Создаем под vault:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-02-vault$ kubectl apply -f manifests/10-vault-pod.yml
pod/14.2-netology-vault created

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-02-vault$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
14.2-netology-vault                   1/1     Running   0          42s
nfs-server-nfs-server-provisioner-0   1/1     Running   0          6d23h

```
Узнаем IP адрес пода (один из способов через -o json):
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-02-vault$ kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
[{"ip":"10.244.2.53"}]
```
Поднимаем тестовую машину (под) с которой будем выполнять запись и чтение секрета из Vault:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-02-vault$ kubectl run -it fedora --image=fedora --restart=Never -- sh
If you don't see a command prompt, try pressing enter.
sh-5.2#

dgolodnikov@pve-vm1:~$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
14.2-netology-vault                   1/1     Running   0          7m25s
fedora                                1/1     Running   0          25s
nfs-server-nfs-server-provisioner-0   1/1     Running   0          7d
```
Внутри пода fedora поставить hvac (питон модуль для работы с vault):
```
sh-5.2# dnf -y install pip
Fedora 37 - 
...
Installed:
  python3-pip-22.2.2-3.fc37.noarch                                        python3-setuptools-62.6.0-2.fc37.noarch

Complete!

sh-5.2# pip install hvac
Collecting hvac
...
Successfully built pyhcl
Installing collected packages: pyhcl, urllib3, idna, charset-normalizer, certifi, requests, hvac
Successfully installed certifi-2022.12.7 charset-normalizer-2.1.1 hvac-1.0.2 idna-3.4 pyhcl-0.4.4 requests-2.28.1 urllib3-1.26.13
```

Выполняем построчно программу для записи и чтения секрета:

```
sh-5.2# python3
Python 3.11.0 (main, Oct 24 2022, 00:00:00) [GCC 12.2.1 20220819 (Red Hat 12.2.1-2)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>
>>> import hvac
>>> client = hvac.Client(
...     url='http://10.244.2.53:8200',
...     token='aiphohTaa0eeHei'
... )
>>> client.is_authenticated()
True
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac',
...     secret=dict(netology='Big secret!!! In VAULT! '),
... )
{'request_id': '4e650fad-0da1-d2b3-b8e6-75595286a45a', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2022-12-25T17:21:31.949387185Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>>
>>> client.secrets.kv.v2.read_secret_version(
...     path='hvac',
... )
{'request_id': 'af9448c5-ee83-44aa-582b-2534f75f0a2c', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big secret!!! In VAULT! '}, 'metadata': {'created_time': '2022-12-25T17:21:31.949387185Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>>
```
Выполнена запись и чтение секрета из Vault, ключ: `netology`, значение: `Big secret!!! In VAULT!`.

Посмотрим через веб, для этого 
- допишем label в [манифесте на pod](manifests/10-vault-pod.yml):
```
metadata:
+  labels:
+    app: vault
```
- применим манифест:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-02-vault$ kubectl apply -f manifests/10-vault-pod.yml
pod/14.2-netology-vault configured

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-02-vault$ kubectl get pod 14.2-netology-vault  --show-labels
NAME                  READY   STATUS    RESTARTS   AGE   LABELS
14.2-netology-vault   1/1     Running   0          34m   app=vault
```
- пропишем [сервис](manifests/20-vault-svc.yml) с типом NodePort и применим его:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-02-vault$ kubectl apply -f manifests/20-vault-svc.yml
service/vault created

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-02-vault$ kubectl get svc vault
NAME    TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
vault   NodePort   10.107.244.37   <none>        8200:30010/TCP   30s
```
- заходим через бразуер на установленный порт, т.е. в моем случае http://192.168.8.30:30010. Для авторизации прописываем токен из конфигурации/манифеста `aiphohTaa0eeHei`. Заходим в раздел Secrets и ищем [и находим наш секрет (скриншот)](Vault_web_screen01.PNG).


## Задача 2 (*): Работа с секретами внутри модуля

* На основе образа fedora создать модуль;
* Создать секрет, в котором будет указан токен;
* Подключить секрет к модулю;
* Запустить модуль и проверить доступность сервиса Vault.

### Выполнение:

Будет выполнено позже (после достижения 70% модуля).
