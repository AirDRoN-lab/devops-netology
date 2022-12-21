# Домашнее задание к занятию "13.3 работа с kubectl"
## Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

## Подготвка

Поставим kubectl на локальную машину:
1) скачиваем https://dl.k8s.io/release/v1.26.0/bin/windows/amd64/kubectl.exe
2) добавляем путь в переменные окружения PATH (Панель Управления -> Система -> Переменные среды)
3) в домашней директории создаем директорию .kube, копируем конфиг и проверяем:

```
  21/12/2022   23:25.00   /home/mobaxterm  kubectl get nodes
NAME             STATUS   ROLES           AGE   VERSION
pve-kube-cp1     Ready    control-plane   22d   v1.25.4
pve-kube-node1   Ready    <none>          21d   v1.25.4
pve-kube-node2   Ready    <none>          21d   v1.25.4
```

Выполним установку praqma/network-multitool:alpine-extra для тестирования доступности узлов изнутри кластера, подготовим манифест [10-multitool.yaml](manifests/10-multitool.yaml):


## Ответ

Проверим доступ через `exec` подготовленного пода network-multitool.

```
dgolodnikov@pve-vm1:~$ kubectl exec -it multitool-68cf8b75ff-fhcvb -- psql postgres://postgres:postgres@dbweb:5432 -c "\l"
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 news      | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)
```
```
dgolodnikov@pve-vm1:~$ kubectl exec -it multitool-68cf8b75ff-fhcvb -- curl front
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
```
```
dgolodnikov@pve-vm1:~$  kubectl exec -it multitool-68cf8b75ff-fhcvb -- curl back:9000
{"detail":"Not Found"}
```

Выполним `port-forward` на локальную машину:
```
  22/12/2022   00:33.16   /home/mobaxterm  kubectl port-forward pods front-7fff466675-j8sb2 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
Handling connection for 8080
```
Проверям в браузере, [Localhost_pod_front.PNG](Localhost_pod_front.PNG). Все ок, идем дальше.

```
  22/12/2022   00:36.07   /home/mobaxterm  kubectl port-forward pods/back-56849f497d-ncjh2 8080:9000
Forwarding from 127.0.0.1:8080 -> 9000
Forwarding from [::1]:8080 -> 9000
Handling connection for 8080
Handling connection for 8080
```
Проверям в браузере, [Localhost_pod_back.PNG](Localhost_pod_back.PNG). Все ок, идем дальше.

```
  22/12/2022   00:36.59   /home/mobaxterm  kubectl port-forward pods/dbweb-0 5432:5432
Forwarding from 127.0.0.1:5432 -> 5432
Forwarding from [::1]:5432 -> 5432
Handling connection for 5432
Handling connection for 5432
Handling connection for 5432
Handling connection for 5432
Handling connection for 5432
```
Запускаем DBeaver, проверяем: [Localhost_pod_dbweb.PNG](Localhost_pod_dbweb.PNG). Данные есть, все ок. 


## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.

## Ответ:

```
dgolodnikov@pve-vm1:~$ kubectl get deploy
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
back        1/1     1            1           92m
front       1/1     1            1           92m
multitool   1/1     1            1           74m

dgolodnikov@pve-vm1:~$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
back-56849f497d-ncjh2                 1/1     Running   0          90m
dbweb-0                               1/1     Running   0          92m
front-7fff466675-j8sb2                1/1     Running   0          92m
multitool-68cf8b75ff-fhcvb            1/1     Running   0          73m
nfs-server-nfs-server-provisioner-0   1/1     Running   0          3d1h
```
Выполнияем скейлинг до 3х реплик:
```
dgolodnikov@pve-vm1:~$ kubectl scale --replicas=3 deploy/front
deployment.apps/front scaled
dgolodnikov@pve-vm1:~$ kubectl scale --replicas=3 deploy/back
deployment.apps/back scaled
```
Посмотрим раширенный вывод `kubectl get pods`:
```
dgolodnikov@pve-vm1:~$ kubectl get pods -o wide
NAME                                  READY   STATUS    RESTARTS   AGE    IP            NODE             NOMINATED NODE   READINESS GATES
back-56849f497d-fchg4                 1/1     Running   0          3s     10.244.2.24   pve-kube-node2   <none>           <none>
back-56849f497d-ncjh2                 1/1     Running   0          92m    10.244.1.16   pve-kube-node1   <none>           <none>
back-56849f497d-tnttc                 1/1     Running   0          3s     10.244.2.23   pve-kube-node2   <none>           <none>
dbweb-0                               1/1     Running   0          93m    10.244.1.15   pve-kube-node1   <none>           <none>
front-7fff466675-6wqj8                1/1     Running   0          7s     10.244.1.17   pve-kube-node1   <none>           <none>
front-7fff466675-btj5f                1/1     Running   0          7s     10.244.2.22   pve-kube-node2   <none>           <none>
front-7fff466675-j8sb2                1/1     Running   0          93m    10.244.2.19   pve-kube-node2   <none>           <none>
multitool-68cf8b75ff-fhcvb            1/1     Running   0          75m    10.244.2.21   pve-kube-node2   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          3d1h   10.244.1.8    pve-kube-node1   <none>           <none>
```
Посмотрим describe:
```
dgolodnikov@pve-vm1:~$ kubectl describe pods back-56849f497d-fchg4
Name:             back-56849f497d-fchg4
Namespace:        default
Priority:         0
Service Account:  default
Node:             pve-kube-node2/192.168.8.32
Start Time:       Wed, 21 Dec 2022 18:21:17 +0000
Labels:           app=backweb
                  pod-template-hash=56849f497d
Annotations:      <none>
Status:           Running
IP:               10.244.2.24
IPs:
  IP:           10.244.2.24
Controlled By:  ReplicaSet/back-56849f497d
Containers:
  backend:
    Container ID:   containerd://a58a516ec8ffe511d27ec2e331f33fa057b35f0514a02309a1a4066b8a91b58b
    Image:          dgolodnikov/netobackend:1.0.0
    Image ID:       docker.io/dgolodnikov/netobackend@sha256:fbab0cd310e225e1bf8e9c3ba97d51edf8a12e0fa9f9f3914b8464fb60c2e164
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 21 Dec 2022 18:21:18 +0000
    Ready:          True
    Restart Count:  0
    Environment:
      DATABASE_URL:  postgres://postgres:postgres@dbweb:5432/news
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-b4bh2 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-b4bh2:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  90s   default-scheduler  Successfully assigned default/back-56849f497d-fchg4 to pve-kube-node2
  Normal  Pulled     90s   kubelet            Container image "dgolodnikov/netobackend:1.0.0" already present on machine
  Normal  Created    89s   kubelet            Created container backend
  Normal  Started    89s   kubelet            Started container backend

dgolodnikov@pve-vm1:~$ kubectl describe pods front-7fff466675-6wqj8
Name:             front-7fff466675-6wqj8
Namespace:        default
Priority:         0
Service Account:  default
Node:             pve-kube-node1/192.168.8.31
Start Time:       Wed, 21 Dec 2022 18:21:13 +0000
Labels:           app=frontweb
                  pod-template-hash=7fff466675
Annotations:      <none>
Status:           Running
IP:               10.244.1.17
IPs:
  IP:           10.244.1.17
Controlled By:  ReplicaSet/front-7fff466675
Containers:
  front:
    Container ID:   containerd://142f8f5f02cefd21a7a2c2fe2df1d1227425bd0e494fcf459479b8071dcd68ad
    Image:          dgolodnikov/netofrontend:1.0.0
    Image ID:       docker.io/dgolodnikov/netofrontend@sha256:550e0c2f97925312bbedc87a9cdc14d95d14f304859b22c977fe66f4f8f8a034
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 21 Dec 2022 18:21:14 +0000
    Ready:          True
    Restart Count:  0
    Environment:
      BASE_URL:  http://backweb:30001
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5wgqw (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-5wgqw:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  102s  default-scheduler  Successfully assigned default/front-7fff466675-6wqj8 to pve-kube-node1
  Normal  Pulled     102s  kubelet            Container image "dgolodnikov/netofrontend:1.0.0" already present on machine
  Normal  Created    102s  kubelet            Created container front
  Normal  Started    101s  kubelet            Started container front

```
Все, ок. Сократим кол-во реплик до 1й.

```
dgolodnikov@pve-vm1:~$ kubectl scale --replicas=1 deploy/back
deployment.apps/back scaled
dgolodnikov@pve-vm1:~$ kubectl scale --replicas=1 deploy/front
deployment.apps/front scaled

dgolodnikov@pve-vm1:~$ kubectl get pods -o wide
NAME                                  READY   STATUS        RESTARTS   AGE     IP            NODE             NOMINATED NODE   READINESS GATES
back-56849f497d-fchg4                 1/1     Terminating   0          4m58s   10.244.2.24   pve-kube-node2   <none>           <none>
back-56849f497d-ncjh2                 1/1     Running       0          97m     10.244.1.16   pve-kube-node1   <none>           <none>
back-56849f497d-tnttc                 1/1     Terminating   0          4m58s   10.244.2.23   pve-kube-node2   <none>           <none>
dbweb-0                               1/1     Running       0          98m     10.244.1.15   pve-kube-node1   <none>           <none>
front-7fff466675-6wqj8                1/1     Running       0          5m2s    10.244.1.17   pve-kube-node1   <none>           <none>
multitool-68cf8b75ff-fhcvb            1/1     Running       0          80m     10.244.2.21   pve-kube-node2   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running       0          3d1h    10.244.1.8    pve-kube-node1   <none>           <none>
```
Видим, что кол-во реплик сокращается до 1 (поды с бекендом в процессе подыхания). Все, ок. Ожидаемый результат совпадает с реальностью.


