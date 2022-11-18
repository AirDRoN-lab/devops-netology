# Домашнее задание к занятию "12.1 Компоненты Kubernetes"

Вы DevOps инженер в крупной компании с большим парком сервисов. Ваша задача — разворачивать эти продукты в корпоративном кластере. 

## Задача 1: Установить Minikube

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине Minikube.

### Как поставить на AWS:
- создать EC2 виртуальную машину (Ubuntu Server 20.04 LTS (HVM), SSD Volume Type) с типом **t3.small**. Для работы потребуется настроить Security Group для доступа по ssh. Не забудьте указать keypair, он потребуется для подключения.
- подключитесь к серверу по ssh (ssh ubuntu@<ipv4_public_ip> -i <keypair>.pem)
- установите миникуб и докер следующими командами:
  - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  - chmod +x ./kubectl
  - sudo mv ./kubectl /usr/local/bin/kubectl
  - sudo apt-get update && sudo apt-get install docker.io conntrack -y
  - curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
- проверить версию можно командой minikube version
- переключаемся на root и запускаем миникуб: minikube start --vm-driver=none
- после запуска стоит проверить статус: minikube status
- запущенные служебные компоненты можно увидеть командой: kubectl get pods --namespace=kube-system

### Для сброса кластера стоит удалить кластер и создать заново:
- minikube delete
- minikube start --vm-driver=none

Возможно, для повторного запуска потребуется выполнить команду: sudo sysctl fs.protected_regular=0

Инструкция по установке Minikube - [ссылка](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)

**Важно**: t3.small не входит во free tier, следите за бюджетом аккаунта и удаляйте виртуалку.

## Задача 2: Запуск Hello World
После установки Minikube требуется его проверить. Для этого подойдет стандартное приложение hello world. А для доступа к нему потребуется ingress.

- развернуть через Minikube тестовое приложение по [туториалу](https://kubernetes.io/ru/docs/tutorials/hello-minikube/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-minikube)
- установить аддоны ingress и dashboard

## Задача 3: Установить kubectl

Подготовить рабочую машину для управления корпоративным кластером. Установить клиентское приложение kubectl.
- подключиться к minikube 
- проверить работу приложения из задания 2, запустив port-forward до кластера

## Задача 4 (*): собрать через ansible (необязательное)

Профессионалы не делают одну и ту же задачу два раза. Давайте закрепим полученные навыки, автоматизировав выполнение заданий  ansible-скриптами. При выполнении задания обратите внимание на доступные модули для k8s под ansible.
 - собрать роль для установки minikube на aws сервисе (с установкой ingress)
 - собрать роль для запуска в кластере hello world
  
  ---
# Ответы:

## Задача 1: Установить Minikube

Установка minikube:
```sh
vagrant@server3:~$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
vagrant@server3:~$ sudo install minikube-linux-amd64 /usr/local/bin/minikube
vagrant@server3:~$  minikube version
minikube version: v1.28.0

Пропсиываем ресурсы для minikube:
```sh
vagrant@server3:~$ cat .minikube/config/config.json
{
    "cpus": 2,
    "driver": "docker",
    "memory": "2200"
}
```

Запускаем:
```
vagrant@server3:~/REPO$ minikube start
vagrant@server3:~/REPO$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

## Задача 2: Запуск Hello World

```
vagrant@server3:~$ minikube addons enable dashboard metrics-server ingress
vagrant@server3:~/REPO$ minikube addons list
|-----------------------------|----------|--------------|--------------------------------|
|         ADDON NAME          | PROFILE  |    STATUS    |           MAINTAINER           |
|-----------------------------|----------|--------------|--------------------------------|
| ambassador                  | minikube | disabled     | 3rd party (Ambassador)         |
| auto-pause                  | minikube | disabled     | Google                         |
| cloud-spanner               | minikube | disabled     | Google                         |
| csi-hostpath-driver         | minikube | disabled     | Kubernetes                     |
| dashboard                   | minikube | enabled ✅   | Kubernetes                     |
| default-storageclass        | minikube | enabled ✅   | Kubernetes                     |
| efk                         | minikube | disabled     | 3rd party (Elastic)            |
| freshpod                    | minikube | disabled     | Google                         |
| gcp-auth                    | minikube | disabled     | Google                         |
| gvisor                      | minikube | disabled     | Google                         |
| headlamp                    | minikube | disabled     | 3rd party (kinvolk.io)         |
| helm-tiller                 | minikube | disabled     | 3rd party (Helm)               |
| inaccel                     | minikube | disabled     | 3rd party (InAccel             |
|                             |          |              | [info@inaccel.com])            |
| ingress                     | minikube | enabled ✅   | Kubernetes                     |
| ingress-dns                 | minikube | disabled     | Google                         |
| istio                       | minikube | disabled     | 3rd party (Istio)              |
| istio-provisioner           | minikube | disabled     | 3rd party (Istio)              |
| kong                        | minikube | disabled     | 3rd party (Kong HQ)            |
| kubevirt                    | minikube | disabled     | 3rd party (KubeVirt)           |
| logviewer                   | minikube | disabled     | 3rd party (unknown)            |
| metallb                     | minikube | disabled     | 3rd party (MetalLB)            |
| metrics-server              | minikube | enabled ✅   | Kubernetes                     |
| nvidia-driver-installer     | minikube | disabled     | Google                         |
| nvidia-gpu-device-plugin    | minikube | disabled     | 3rd party (Nvidia)             |
| olm                         | minikube | disabled     | 3rd party (Operator Framework) |
| pod-security-policy         | minikube | disabled     | 3rd party (unknown)            |
| portainer                   | minikube | disabled     | 3rd party (Portainer.io)       |
| registry                    | minikube | disabled     | Google                         |
| registry-aliases            | minikube | disabled     | 3rd party (unknown)            |
| registry-creds              | minikube | disabled     | 3rd party (UPMC Enterprises)   |
| storage-provisioner         | minikube | enabled ✅   | Google                         |
| storage-provisioner-gluster | minikube | disabled     | 3rd party (Gluster)            |
| volumesnapshots             | minikube | disabled     | Kubernetes                     |
|-----------------------------|----------|--------------|--------------------------------|

vagrant@server3:~/REPO$ kubectl get pods --namespace=kubernetes-dashboard
NAME                                        READY   STATUS    RESTARTS   AGE
dashboard-metrics-scraper-b74747df5-lwkfm   1/1     Running   0          12h
kubernetes-dashboard-57bbdc5f89-56z4w       1/1     Running   0          12h

vagrant@server3:~/REPO$ kubectl proxy --address 0.0.0.0 kubernetes-dashboard-57bbdc5f89-56z4w  8001:80 --namespace=kubernetes-dashboard --disable-filter=true

vagrant@server3:~/REPO$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/vagrant/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Thu, 17 Nov 2022 04:44:45 UTC
        provider: minikube.sigs.k8s.io
        version: v1.28.0
      name: cluster_info
    server: https://192.168.49.2:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Thu, 17 Nov 2022 04:44:45 UTC
        provider: minikube.sigs.k8s.io
        version: v1.28.0
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /home/vagrant/.minikube/profiles/minikube/client.crt
    client-key: /home/vagrant/.minikube/profiles/minikube/client.key

```
[Скриншот дашборда](Kuber_dashboard.PNG)

```
vagrant@server3:~/REPO$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
deployment.apps/hello-node created

vagrant@server3:~/REPO$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           2m35s

vagrant@server3:~/REPO$ kubectl get pods
NAME                         READY   STATUS    RESTARTS      AGE
hello-node-697897c86-tmzw9   1/1     Running   0             2m38s

vagrant@server3:~/REPO$ kubectl get events
LAST SEEN   TYPE     REASON              OBJECT                            MESSAGE
4m1s        Normal   Scheduled           pod/hello-node-697897c86-tmzw9    Successfully assigned default/hello-node-697897c86-tmzw9 to minikube
4m          Normal   Pulling             pod/hello-node-697897c86-tmzw9    Pulling image "k8s.gcr.io/echoserver:1.4"
2m16s       Normal   Pulled              pod/hello-node-697897c86-tmzw9    Successfully pulled image "k8s.gcr.io/echoserver:1.4" in 1m44.50749297s
2m14s       Normal   Created             pod/hello-node-697897c86-tmzw9    Created container echoserver
2m13s       Normal   Started             pod/hello-node-697897c86-tmzw9    Started container echoserver
4m2s        Normal   SuccessfulCreate    replicaset/hello-node-697897c86   Created pod: hello-node-697897c86-tmzw9
4m2s        Normal   ScalingReplicaSet   deployment/hello-node             Scaled up replica set hello-node-697897c86 to 1

```

## Задача 3: Установить kubectl

Установка kubectl:
```
vagrant@server3:~$ curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
vagrant@server3:~$ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
vagrant@server3:~$  kubectl version --client --output=yaml
clientVersion:
  buildDate: "2022-10-12T10:57:26Z"
  compiler: gc
  gitCommit: 434bfd82814af038ad94d62ebe59b133fcb50506
  gitTreeState: clean
  gitVersion: v1.25.3
  goVersion: go1.19.2
  major: "1"
  minor: "25"
  platform: linux/amd64
kustomizeVersion: v4.5.7

```

Сделаем под hello-node доступным за пределами кластера. Запустим сервис.
```
vagrant@server3:~/REPO$ kubectl expose deployment hello-node --type=LoadBalancer --port=8080
service/hello-node exposed

vagrant@server3:~/REPO$ kubectl get services
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.106.123.65   <pending>     8080:31159/TCP   11s
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          45h

vagrant@server3:~/REPO$ minikube service hello-node
|-----------|------------|-------------|---------------------------|
| NAMESPACE |    NAME    | TARGET PORT |            URL            |
|-----------|------------|-------------|---------------------------|
| default   | hello-node |        8080 | http://192.168.49.2:31159 |
|-----------|------------|-------------|---------------------------|
* Opening service default/hello-node in default browser...
  http://192.168.49.2:31159
```

Проверяем с помощью curl:
```
vagrant@server3:~/REPO$ curl http://192.168.49.2:31159/
CLIENT VALUES:
client_address=172.17.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://192.168.49.2:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=192.168.49.2:31159
user-agent=curl/7.81.0
BODY:
-no body in request-
```

Вариант со сборкой своего Docker образа "Hello World", собираем образ по туториалу k8s (ссылка выше):
```
vagrant@server3:~$ docker build -t hello-k8s:1.0.0 .
vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-01-intro/hello-k8s$ docker image ls
REPOSITORY                                      TAG       IMAGE ID       CREATED         SIZE
hello-k8s                                       1.0.0     a0cf79a363fa   12 hours ago    660MB

vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-01-intro/hello-k8s$ kubectl create deployment hello-k8s --image=hello-k8s:1.0.0 --port=8080
deployment.apps/hello-k8s created

vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-01-intro/hello-k8s$ kubectl expose deployment hello-k8s --type=NodePort
service/hello-k8s exposed

vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-01-intro/hello-k8s$ kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-k8s    NodePort    10.107.38.239   <none>        8080:31126/TCP   21s

vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-01-intro/hello-k8s$ minikube service hello-k8s
|-----------|-----------|-------------|---------------------------|
| NAMESPACE |   NAME    | TARGET PORT |            URL            |
|-----------|-----------|-------------|---------------------------|
| default   | hello-k8s |        8080 | http://192.168.49.2:31126 |
|-----------|-----------|-------------|---------------------------|
* Opening service default/hello-k8s in default browser...
  http://192.168.49.2:31126

```

Проверяем с помощью curl:
```
vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-01-intro/hello-k8s$ curl http://192.168.49.2:31126
Hello k8s Beginners!
```
