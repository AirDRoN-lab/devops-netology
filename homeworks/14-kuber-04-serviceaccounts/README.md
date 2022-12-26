# Домашнее задание к занятию "14.4 Сервис-аккаунты"

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать сервис-аккаунт?

```
kubectl create serviceaccount netology
```

### Как просмотреть список сервис-акаунтов?

```
kubectl get serviceaccounts
kubectl get serviceaccount
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get serviceaccount netology -o yaml
kubectl get serviceaccount default -o json
```

### Как выгрузить сервис-акаунты и сохранить его в файл?

```
kubectl get serviceaccounts -o json > serviceaccounts.json
kubectl get serviceaccount netology -o yaml > netology.yml
```

### Как удалить сервис-акаунт?

```
kubectl delete serviceaccount netology
```

### Как загрузить сервис-акаунт из файла?

```
kubectl apply -f netology.yml
```

## Ответ

Создадим сервисные аккаунт netology в namespace default:

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$ kubectl create serviceaccount netology
serviceaccount/netology created
```
Посмотрим текущие сервисный аккаунты в текущем namespace:

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$ kubectl get serviceaccounts
NAME                                SECRETS   AGE
default                             0         27d
netology                            0         102s
nfs-server-nfs-server-provisioner   0         8d
```

Для более подробного вывода можно использовать вывод в yaml или json:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$ kubectl get serviceaccount netology -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-12-26T18:23:57Z"
  name: netology
  namespace: default
  resourceVersion: "2226983"
  uid: 2fac5dad-a5da-419e-a598-eb7c2eef8109

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$ kubectl get serviceaccount default -o json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2022-11-28T18:54:10Z",
        "name": "default",
        "namespace": "default",
        "resourceVersion": "336",
        "uid": "fc1c403e-3456-442f-b5d5-adf130f4f7d6"
    }
}
```

Сохраним аккаунт netology в файл (также сохраним все аккаунты текущего namespace в yml):
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$
 kubectl get serviceaccounts -o json > serviceaccounts.json
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$
 kubectl get serviceaccount netology -o yaml > netology.yml
```

Попробуем удалить и загрузить из файла (создан выше) сервисный аккаунт:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$ kubectl delete serviceaccount netology
serviceaccount "netology" deleted
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$ kubectl apply -f netology.yml
serviceaccount/netology created
```
Все ок.

## Задача 2 (*): Работа с сервис-акаунтами внутри модуля

Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить
доступность API Kubernetes

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Просмотреть переменные среды

```
env | grep KUBE
```

Получить значения переменных

```
K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
SADIR=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat $SADIR/token)
CACERT=$SADIR/ca.crt
NAMESPACE=$(cat $SADIR/namespace)
```

Подключаемся к API

```
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
```

В случае с minikube может быть другой адрес и порт, который можно взять здесь

```
cat ~/.kube/config
```

или здесь

```
kubectl cluster-info
```

## Ответ

Запустим тестовый pod на тестовой зоне:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-04-serviceaccounts$ kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
If you don't see a command prompt, try pressing enter.
sh-5.2#

```
Посмотрим текущие переменные окружения внутри пода:
```
sh-5.2# env | grep KUBE
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
```
Присваимваем переменные для подклчения к Kubernetes:
```
sh-5.2# K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
sh-5.2# SADIR=/var/run/secrets/kubernetes.io/serviceaccount
sh-5.2# TOKEN=$(cat $SADIR/token)
sh-5.2# CACERT=$SADIR/ca.crt
sh-5.2# NAMESPACE=$(cat $SADIR/namespace)
```

Проверим переменные:
```
sh-5.2# echo $K8S && echo $SADIR  && echo $TOKEN && echo $CACERT && echo $NAMESPACE
https://10.96.0.1:443
/var/run/secrets/kubernetes.io/serviceaccount
eyJhbGciOiJSUzI1NiIsImtpZCI6IlhLM1UtcFROOGRRNXdMT1NHSVhheVQ0cUctN01STldTMnp0bEtQTk1qekUifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzAzNjE1Njg3LCJpYXQiOjE2NzIwNzk2ODcsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJmZWRvcmEiLCJ1aWQiOiJhZWVkYjc4MC01OWMzLTQ1OWQtYjQ1YS1iOTA3MWUxMGQ1OWQifSwic2VydmljZWFjY291bnQiOnsibmFtZSI6ImRlZmF1bHQiLCJ1aWQiOiJmYzFjNDAzZS0zNDU2LTQ0MmYtYjVkNS1hZGYxMzBmNGY3ZDYifSwid2FybmFmdGVyIjoxNjcyMDgzMjk0fSwibmJmIjoxNjcyMDc5Njg3LCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpkZWZhdWx0In0.m1wWOCPd0U_On-etQ1LwZEtWRsgy0QIr7Ejbwe-wD3UW59Pnc7h1fRgj3x0sK7G1qa6wslTYmm5fc-vdZiM_28TyTp0Dh1dU4Dlx0JwXAluCxjxCNHX_JJRstvbxdox155wKCfnbx4efvcVP1Gk_NxSlJz32WYkBMbkg1yCQclj5vvj9g7QvvWm5t-rXmsssaD79QH9WdD4CWfOBs4Zh05rHrxlQKuUs_s0tK2Gn6Qbb90UJqj_d0L8Z0zLQrh4n56ga1Va6SxKlDgTyXKMJIXSugFEnWrxEX8IBhCqdY8yo5zuzH31fwqghr01beFhcA4hw3peYsbMpmLweTZqSYQ
/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
default
```
Подключаемся к куберу по API:
```
sh-5.2# curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
```
Вывод сохранен в файл [K8S_api_v1.yml](K8S_api_v1.yml), т.к. обьемный. 

Все ок. ДЗ выполнено. 