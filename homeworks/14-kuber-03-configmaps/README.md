# Домашнее задание к занятию "14.3 Карты конфигураций"

## Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать карту конфигураций?

```
kubectl create configmap nginx-config --from-file=nginx.conf
kubectl create configmap domain --from-literal=name=netology.ru
```

### Как просмотреть список карт конфигураций?

```
kubectl get configmaps
kubectl get configmap
```

### Как просмотреть карту конфигурации?

```
kubectl get configmap nginx-config
kubectl describe configmap domain
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get configmap nginx-config -o yaml
kubectl get configmap domain -o json
```

### Как выгрузить карту конфигурации и сохранить его в файл?

```
kubectl get configmaps -o json > configmaps.json
kubectl get configmap nginx-config -o yaml > nginx-config.yml
```

### Как удалить карту конфигурации?

```
kubectl delete configmap nginx-config
```

### Как загрузить карту конфигурации из файла?

```
kubectl apply -f nginx-config.yml
```

## Ответ:

Выполняем команды согласно описания в домашнем кластере. Создаем сущность configmap из файла и литерал:

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl create configmap nginx-config --from-file=nginx.conf
configmap/nginx-config created
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl create configmap domain --from-literal=name=netology.ru
configmap/domain created
```

Изучаем какие есть confogmaps в кластере (какой-то левый затисался kube-root-ca.crt =) ):
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl get configmaps
NAME               DATA   AGE
domain             1      35s
kube-root-ca.crt   1      27d
nginx-config       1      62s
```

Более подробное описание можно получить классически через describe для `cm nginx-config`:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl describe configmaps nginx-config
Name:         nginx-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----
server {
    listen 80;
    server_name  netology.ru www.netology.ru;
    access_log  /var/log/nginx/domains/netology.ru-access.log  main;
    error_log   /var/log/nginx/domains/netology.ru-error.log info;
    location / {
        include proxy_params;
        proxy_pass http://10.10.10.10:8080/;
    }
}


BinaryData
====

Events:  <none>
```

Описание  через describe для `cm domain`:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl describe configmaps domain
Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>
```

Также описание можно получить в yaml формате:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl get configmap nginx-config -o yaml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-12-26T16:05:00Z"
  name: nginx-config
  namespace: default
  resourceVersion: "2211121"
  uid: 3656e6f0-23c0-4d49-830b-3183c20e4e57
```

Либо описание можно получить в json формате:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl get configmap nginx-config -o json
{
    "apiVersion": "v1",
    "data": {
        "nginx.conf": "server {\n    listen 80;\n    server_name  netology.ru www.netology.ru;\n    access_log  /var/log/nginx/domains/netology.ru-access.log  main;\n    error_log   /var/log/nginx/domains/netology.ru-error.log info;\n    location / {\n        include proxy_params;\n        proxy_pass http://10.10.10.10:8080/;\n    }\n}\n"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-12-26T16:05:00Z",
        "name": "nginx-config",
        "namespace": "default",
        "resourceVersion": "2211121",
        "uid": "3656e6f0-23c0-4d49-830b-3183c20e4e57"
    }
}
```

Удаляем конфигмап и загружаем обрытно из файла (который срздали выше):
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl delete configmap nginx-config
configmap "nginx-config" deleted

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps$ kubectl apply -f nginx-config.yml
configmap/nginx-config created
```

Все ок

## Задача 2 (*): Работа с картами конфигураций внутри модуля

Выбрать любимый образ контейнера, подключить карты конфигураций и проверить
их доступность как в виде переменных окружения, так и в виде примонтированного
тома

## Ответ

Конфигмап создали, а как применять не ясно. Соответсвенно создаем манифест. CM domain монтируем как переменную окружения, а CM nginx-config как volume в файл /etc/config/nginx.

В итоге манифест получился следующий: [manifest/10-task2_pods_w_cm.yaml](manifest/10-task2_pods_w_cm.yaml)

Применяем:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps/manifest$ kubectl apply -f 10-task2_pods_w_cm.yaml
deployment.apps/front created
```

Проверяем configmap в файле:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps/manifest$ kubectl exec -it front-58dd77cc6c-f8fsj -- cat /etc/config/nginx   server {
    listen 80;
    server_name  netology.ru www.netology.ru;
    access_log  /var/log/nginx/domains/netology.ru-access.log  main;
    error_log   /var/log/nginx/domains/netology.ru-error.log info;
    location / {
        include proxy_params;
        proxy_pass http://10.10.10.10:8080/;
    }
}
```

Проверяем configmap в переменной окружения:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-03-configmaps/manifest$ kubectl exec -it front-58dd77cc6c-f8fsj -- printenv | grep name
name=netology.ru
```

Все ок, configmap-ы видны внутри пода. ДЗ выполнено.
