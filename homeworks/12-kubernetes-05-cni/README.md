# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.

## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

## Ответ

Выполняем установку kubectl-calico с https://github.com/projectcalico/calico/tree/master/calicoctl
```
curl -L https://github.com/projectcalico/calico/releases/download/v3.24.5/calicoctl-linux-amd64 -o kubectl-calico
sudo chmod +x kubectl-calico
sudo mv kubectl-calico /usr/bin/

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl-calico version
Client Version:    v3.24.5
Git commit:        f1a1611ac
Cluster Version:   v3.23.3
Cluster Type:      kubespray,kubeadm,kdd,k8s

```

Создаем два пода используя созданнй ранее контейнер https://hub.docker.com/repository/docker/dgolodnikov/hello-k8s. Используем [deployment](deployment2.yml):

```yml
---
apiVersion: "apps/v1"
kind: "Deployment"
metadata:
  name: "dpl-javacurl"
  namespace: "default"
  labels:
    app: "lb-javacurl"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: "lb-javacurl"
  template:
    metadata:
      labels:
        app: "lb-javacurl"
    spec:
      containers:
        - name: "cnt-javacurl"
          image: "dgolodnikov/hello-k8s:1"
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "500m"
```

Проверяем статус:
```s
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl apply -f deployment2.yml
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl get pods -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
dpl-javacurl-7484f44746-g4zlj   1/1     Running   0          2m29s   10.233.71.8    node3   <none>           <none>
dpl-javacurl-7484f44746-rtklh   1/1     Running   0          106s    10.233.75.9    node2   <none>           <none>
```

Создаем сервис с `type: NodePort` для доступа в кластер снаружи и проверяем статус:

```yaml
apiVersion: v1
kind: Service
metadata: 
  name: srv-javacurl
spec:
  selector:
    app: lb-javacurl
  type: NodePort
  ports:
    - name: http
      port: 8080
      targetPort: 8080
      protocol: TCP
```
```s
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl apply -f service.yml
service/srv-javacurl configured
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl get services -o wide
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE     SELECTOR
kubernetes     ClusterIP   10.233.0.1      <none>        443/TCP          2d20h   <none>
srv-javacurl   NodePort    10.233.62.189   <none>        8222:32123/TCP   2m25s   app=lb-javacurl
```
Проверям  сервис снаружи кластера:
```s
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ ifconfig | grep 192.168.8
        inet 192.168.8.21  netmask 255.255.255.0  broadcast 192.168.8.255
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ curl 192.168.8.40:32123
Hello k8s Beginners!
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ curl 192.168.8.41:32123
Hello k8s Beginners!
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ curl 192.168.8.42:32123
Hello k8s Beginners!
```

Создаем GlobalNetworkPolicy и HostEndpoint. Применяем конфигурацию <br>
Использованные материалы: <br>
https://projectcalico.docs.tigera.io/security/protect-hosts 

https://projectcalico.docs.tigera.io/security/tutorials/protect-hosts


```yaml
apiVersion: projectcalico.org/v3
kind: HostEndpoint
metadata:
  name: node2-ens18
  labels:
    host-endpoint: ext-interface
spec:
  interfaceName: ens18
  node: node2
---
apiVersion: projectcalico.org/v3
kind: HostEndpoint
metadata:
  name: node3-ens18
  labels:
    host-endpoint: ext-interface
spec:
  interfaceName: ens18
  node: node3
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
Metadata:
  name: deny-from-untrust-calico
Spec:
  preDNAT: true
  applyOnForward: true
  ingress:
  - action: Log
    protocol: TCP
    destination:
        ports: [32123]
  - action: Deny
    protocol: TCP
    source:
        nets: [192.168.8.21/32]
    destination:
        ports: [32123]
  selector: host-endpoint == 'ext-interface'
```
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl-calico apply -f netpolicy-cal.yml --allow-version-mismatch
Successfully applied 3 resource(s)
```
Провеяем доступ с двух различных хостов снаружи. 192.168.8.21(запрещен) и 192.168.8.40(разрешен): 
```s
dgolodnikov@cp1:~$ ifconfig | grep 192.168.8
        inet 192.168.8.40  netmask 255.255.255.0  broadcast 192.168.8.255
dgolodnikov@cp1:~$ curl 192.168.8.41:32123
Hello k8s Beginners!

```
```s
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ ifconfig | grep 192.168.8
        inet 192.168.8.21  netmask 255.255.255.0  broadcast 192.168.8.255
dgolodnikov@cp1:~$ curl 192.168.8.41:32123
^C
```

Информация из логов systemd использовалась для проверки попадания в политику: 

```S
Dec  4 01:30:07 node3 kernel: [307753.360525] calico-packet: IN=vxlan.calico OUT=cali854fbe58c09 MAC=66:a4:6f:e0:c4:da:66:ca:47:8d:70:51:08:00 SRC=10.233.116.128 DST=10.233.71.8 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=35584 DF PROTO=TCP SPT=10275 DPT=8080 WINDOW=64240 RES=0x00 SYN URGP=0

Dec  5 02:41:49 node2 kernel: [398459.316264] calico-packet: IN=ens18 OUT= MAC=b6:65:07:ed:47:26:76:17:c9:2d:cf:ce:08:00 SRC=192.168.8.21 DST=192.168.8.41 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=43286 DF PROTO=TCP SPT=33898 DPT=32123 WINDOW=64240 RES=0x00 SYN URGP=0

Dec  5 02:41:50 node2 kernel: [398459.965479] calico-packet: IN=ens18 OUT= MAC=b6:65:07:ed:47:26:2a:a1:29:53:55:dd:08:00 SRC=192.168.8.40 DST=192.168.8.41 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=23108 DF PROTO=TCP SPT=34294 DPT=32123 WINDOW=64240 RES=0x00 SYN URGP=0
```

Дополнительно для тестирования сетевой связности между подами использовался [deployment](deployment.yml) с возможностью делать ping из контейнера. Сетевая связность внутри подов есть.

```s
dgolodnikov@pve-vm1:~/REPO/k8s-hello-node$ kubectl get pods -o wide
NAME                       READY   STATUS    RESTARTS   AGE     IP            NODE    NOMINATED NODE   READINESS GATES
k8s-node-fdf4f789b-4sqt6   1/1     Running   0          3m59s   10.233.71.4   node3   <none>           <none>
k8s-node-fdf4f789b-5vjgz   1/1     Running   0          4m2s    10.233.75.4   node2   <none>           <none>
k8s-node-fdf4f789b-hwvgh   1/1     Running   0          3m50s   10.233.75.5   node2   <none>           <none>
k8s-node-fdf4f789b-vcs62   1/1     Running   0          3m50s   10.233.71.5   node3   <none>           <none>

dgolodnikov@pve-vm1:~/REPO/k8s-hello-node$ kubectl exec k8s-node-fdf4f789b-4sqt6 -- ping -c1  10.233.75.4
PING 10.233.75.4 (10.233.75.4): 56 data bytes
64 bytes from 10.233.75.4: seq=0 ttl=62 time=0.371 ms

--- 10.233.75.4 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.371/0.371/0.371 ms

dgolodnikov@pve-vm1:~/REPO/k8s-hello-node$ kubectl exec k8s-node-fdf4f789b-4sqt6 -- ping -c1  10.233.75.5
PING 10.233.75.5 (10.233.75.5): 56 data bytes
64 bytes from 10.233.75.5: seq=0 ttl=62 time=0.421 ms

--- 10.233.75.5 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.421/0.421/0.421 ms

dgolodnikov@pve-vm1:~/REPO/k8s-hello-node$ kubectl exec k8s-node-fdf4f789b-4sqt6 -- ping -c1  10.233.71.5
PING 10.233.71.5 (10.233.71.5): 56 data bytes
64 bytes from 10.233.71.5: seq=0 ttl=63 time=0.155 ms

--- 10.233.71.5 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.155/0.155/0.155 ms
```

## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.

## Ответ 

Установка calicctl (kubectl-calico) была выполнена в предидущем задании. Ниже приведен вывод в рамказ ДЗ:

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl-calico  get ipPool -o wide --allow-version-mismatch
NAME           CIDR             NAT    IPIPMODE   VXLANMODE   DISABLED   DISABLEBGPEXPORT   SELECTOR
default-pool   10.233.64.0/18   true   Never      Always      false      false              all()
```
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl-calico  get profile --allow-version-mismatch
NAME
projectcalico-default-allow
kns.default
kns.kube-node-lease
kns.kube-public
kns.kube-system
ksa.default.default
ksa.kube-node-lease.default
ksa.kube-public.default
ksa.kube-system.attachdetach-controller
ksa.kube-system.bootstrap-signer
ksa.kube-system.calico-kube-controllers
ksa.kube-system.calico-node
ksa.kube-system.certificate-controller
ksa.kube-system.clusterrole-aggregation-controller
ksa.kube-system.coredns
ksa.kube-system.cronjob-controller
ksa.kube-system.daemon-set-controller
ksa.kube-system.default
ksa.kube-system.deployment-controller
ksa.kube-system.disruption-controller
ksa.kube-system.dns-autoscaler
ksa.kube-system.endpoint-controller
ksa.kube-system.endpointslice-controller
ksa.kube-system.endpointslicemirroring-controller
ksa.kube-system.ephemeral-volume-controller
ksa.kube-system.expand-controller
ksa.kube-system.generic-garbage-collector
ksa.kube-system.horizontal-pod-autoscaler
ksa.kube-system.job-controller
ksa.kube-system.kube-proxy
ksa.kube-system.namespace-controller
ksa.kube-system.node-controller
ksa.kube-system.nodelocaldns
ksa.kube-system.persistent-volume-binder
ksa.kube-system.pod-garbage-collector
ksa.kube-system.pv-protection-controller
ksa.kube-system.pvc-protection-controller
ksa.kube-system.replicaset-controller
ksa.kube-system.replication-controller
ksa.kube-system.resourcequota-controller
ksa.kube-system.root-ca-cert-publisher
ksa.kube-system.service-account-controller
ksa.kube-system.service-controller
ksa.kube-system.statefulset-controller
ksa.kube-system.token-cleaner
ksa.kube-system.ttl-after-finished-controller
ksa.kube-system.ttl-controller
```
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/12-kubernetes-05-cni$ kubectl-calico get node -o wide --allow-version-mismatch
NAME    ASN       IPV4              IPV6
cp1     (64512)   192.168.8.40/24
node2   (64512)   192.168.8.41/24
node3   (64512)   192.168.8.42/24
```

PS:
При использовании сервиса с `type: NodePort` используется DNAT для доступа снаружи. Адрес источника, судя по логам в systemd, подменяется на SRC=10.233.116.128 (см.ниже). Данный IP динамический? Его можно увидеть через describe или еще как-то? =)

```
Dec  4 01:30:07 node3 kernel: [307753.360525] calico-packet: IN=vxlan.calico OUT=cali854fbe58c09 MAC=66:a4:6f:e0:c4:da:66:ca:47:8d:70:51:08:00 SRC=10.233.116.128 DST=10.233.71.8 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=35584 DF PROTO=TCP SPT=10275 DPT=8080 WINDOW=64240 RES=0x00 SYN URGP=0
```