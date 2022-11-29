# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.

## Ответ: 

Для развертывания инфраструктуры в Яндекс Облаке используем терраформ, конфигурация манифестов terraform лежит в текущем репозитории, [папка terrform](terraform/). <br> Запуск для удобства через баш скрипт [start.sh](start.sh).

В итоге получены 5 ВМ, адресация ниже:
```
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:
external_ip_address_vm_1 = "158.160.43.129"
external_ip_address_vm_2 = "158.160.43.224"
external_ip_address_vm_3 = "130.193.51.14"
external_ip_address_vm_4 = "158.160.39.36"
external_ip_address_vm_5 = "84.201.156.234"
internal_ip_address_vm_1 = "192.168.250.10"
internal_ip_address_vm_2 = "192.168.250.25"
internal_ip_address_vm_3 = "192.168.250.19"
internal_ip_address_vm_4 = "192.168.250.37"
internal_ip_address_vm_5 = "192.168.250.9"
```

Подготовляем инвентарь для kubespray на мастер машине:
```
dgolodnikov@cp1:~/REPO/$ git clone https://github.com/kubernetes-sigs/kubespray
dgolodnikov@cp1:~/REPO/$ cd kubespray
dgolodnikov@cp1:~/REPO/kubespray$ cat requirements.txt
ansible==5.7.1
ansible-core==2.12.5
cryptography==3.4.8
jinja2==2.11.3
netaddr==0.7.19
pbr==5.4.4
jmespath==0.9.5
ruamel.yaml==0.16.10
ruamel.yaml.clib==0.2.7
MarkupSafe==1.1.1
dgolodnikov@cp1:~/REPO/kubespray$ sudo pip3 install -r requirements.txt
```
Копируем инвентарь в отдельную папку, назовем firstcluster. С помощью билдера создаем hosts.yaml.
```
dgolodnikov@cp1:~/REPO/kubespray$ cp -rfp inventory/sample inventory/mycluster
dgolodnikov@cp1:~/REPO/kubespray$ declare -a IPS=(192.168.250.10 192.168.250.25 192.168.250.19 192.168.250.37 192.168.250.9)
dgolodnikov@cp1:~/REPO/kubespray$ CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```
Корректируем полученный файл до следующего вида:

``` yaml
dgolodnikov@cp1:~/kubespray/inventory/firstcluster$ cat hosts.yaml
all:
  hosts:
    cp1:
      ansible_host: 192.168.250.10
      ip: 192.168.250.10
      access_ip: 192.168.250.10
      ansible_user: dgolodnikov
    node1:
      ansible_host: 192.168.250.25
      ip: 192.168.250.25
      access_ip: 192.168.250.25
      ansible_user: dgolodnikov
    node2:
      ansible_host: 192.168.250.19
      ip: 192.168.250.19
      access_ip: 192.168.250.19
      ansible_user: dgolodnikov
    node3:
      ansible_host: 192.168.250.37
      ip: 192.168.250.37
      access_ip: 192.168.250.37
      ansible_user: dgolodnikov
    node4:
      ansible_host: 192.168.250.9
      ip: 192.168.250.9
      access_ip: 192.168.250.9
      ansible_user: dgolodnikov
  children:
    kube_control_plane:
      hosts:
        cp1:
    kube_node:
      hosts:
        node1:
        node2:
        node3:
        node4:
    etcd:
      hosts:
        cp1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```
Для доступа к кластеру снаружи добавлем строку `supplementary_addresses_in_ssl_keys: [158.160.43.129]` в `inventory/firstcluster/group_vars/k8s_cluster/k8s-cluster.yml` в которой прописываем внешний адрес кластера. Файл конфигурации в полном обьеме [выложен здесь](REPO/devops-netology/homeworks/12-kubernetes-04-install-part-2/k8s-cluster.yml).

Запускаем ансибл для установка кластера с нашим инвентарем. Также запрещаем host cheking в аргументах. Предварительно копируем приватный ключ на мастер ноду, т.к. на всех созданных ВМ залит публичный ключ: 

``` 
dgolodnikov@cp1:~/.kube$ ansible-playbook -i inventory/firstcluster/hosts.yaml --ssh-common-args='-o StrictHostKeyChecking=no' cluster.yml -b -v
```

Копируем конфигурацию кластера для `kubectl`:
```
dgolodnikov@cp1:~$ sudo cp /etc/kubernetes/kubeadm-config.yaml ~/.kube/config
```
Проверяем на мастер ноды, что кластер создан:

```
dgolodnikov@cp1:~$ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   8h    v1.25.4
node1   Ready    <none>          8h    v1.25.4
node2   Ready    <none>          8h    v1.25.4
node3   Ready    <none>          8h    v1.25.4
node4   Ready    <none>          8h    v1.25.4
```
Далее настраиваем удаленное управление согласно задания на локальной машине и проверяем:

```
dgolodnikov@pve-vm1:~$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
dgolodnikov@pve-vm1:~$ chmod +x ./kubectl
dgolodnikov@pve-vm1:~$ sudo mv ./kubectl /usr/local/bin/kubectl

dgolodnikov@pve-vm1:~$ kubectl version -o yaml
clientVersion:
  buildDate: "2022-11-09T13:36:36Z"
  compiler: gc
  gitCommit: 872a965c6c6526caa949f0c6ac028ef7aff3fb78
  gitTreeState: clean
  gitVersion: v1.25.4
  goVersion: go1.19.3
  major: "1"
  minor: "25"
  platform: linux/amd64
kustomizeVersion: v4.5.7
serverVersion:
  buildDate: "2022-11-09T13:29:58Z"
  compiler: gc
  gitCommit: 872a965c6c6526caa949f0c6ac028ef7aff3fb78
  gitTreeState: clean
  gitVersion: v1.25.4
  goVersion: go1.19.3
  major: "1"
  minor: "25"
  platform: linux/amd64
```
Конфигурацию для kubectl делаем по аналогии, как мы делали это выше. Меняем только адрес кластера с 127.0.0.1 на соответсвенно внешний адрес. В нашем случае это https://158.160.43.129:6443. Проверяем:

```
dgolodnikov@pve-vm1:~$ kubectl cluster-info
Kubernetes control plane is running at https://158.160.43.129:6443

dgolodnikov@pve-vm1:~/.kube$ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   8h    v1.25.4
node1   Ready    <none>          8h    v1.25.4
node2   Ready    <none>          8h    v1.25.4
node3   Ready    <none>          8h    v1.25.4
node4   Ready    <none>          8h    v1.25.4

```

Выполним тестовое развертывание:
```
dgolodnikov@pve-vm1:~/.kube$ kubectl create deploy nginx --image=nginx:latest --replicas=3
deployment.apps/nginx created

dgolodnikov@pve-vm1:~/.kube$ kubectl get pods
NAME                     READY   STATUS              RESTARTS   AGE
nginx-6d666844f6-67mtt   0/1     ContainerCreating   0          8s
nginx-6d666844f6-7jhhp   0/1     ContainerCreating   0          8s
nginx-6d666844f6-klrc2   0/1     ContainerCreating   0          8s

dgolodnikov@pve-vm1:~/.kube$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6d666844f6-67mtt   1/1     Running   0          48s
nginx-6d666844f6-7jhhp   1/1     Running   0          48s
nginx-6d666844f6-klrc2   1/1     Running   0          48s

dgolodnikov@pve-vm1:~/.kube$ kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP               NODE    NOMINATED NODE   READINESS GATES
nginx-6d666844f6-67mtt   1/1     Running   0          62s   10.233.71.2      node3   <none>        <none>
nginx-6d666844f6-7jhhp   1/1     Running   0          62s   10.233.74.66     node4   <none>        <none>
nginx-6d666844f6-klrc2   1/1     Running   0          62s   10.233.102.130   node1   <none>        <none>
```
Список подов в namespace=kube-system:
```
dgolodnikov@pve-vm1:~$ kubectl get pods --namespace=kube-system -o wide
NAME                                      READY   STATUS    RESTARTS     AGE   IP               NODE    NOMINATED NODE   READINESS GATES
calico-kube-controllers-d6484b75c-m7b6g   1/1     Running   0            9h    10.233.71.1      node3   <none>           <none>
calico-node-gqccv                         1/1     Running   0            9h    192.168.250.37   node3   <none>           <none>
calico-node-k7fzj                         1/1     Running   0            9h    192.168.250.9    node4   <none>           <none>
calico-node-mw75g                         1/1     Running   0            9h    192.168.250.25   node1   <none>           <none>
calico-node-xpgn7                         1/1     Running   0            9h    192.168.250.10   cp1     <none>           <none>
calico-node-zvj52                         1/1     Running   0            9h    192.168.250.19   node2   <none>           <none>
coredns-588bb58b94-7nzg8                  1/1     Running   0            9h    10.233.75.1      node2   <none>           <none>
coredns-588bb58b94-86l5v                  1/1     Running   0            9h    10.233.102.129   node1   <none>           <none>
dns-autoscaler-5b9959d7fc-nvdwg           1/1     Running   0            9h    10.233.74.65     node4   <none>           <none>
kube-apiserver-cp1                        1/1     Running   1            9h    192.168.250.10   cp1     <none>           <none>
kube-controller-manager-cp1               1/1     Running   2 (9h ago)   9h    192.168.250.10   cp1     <none>           <none>
kube-proxy-9ngmj                          1/1     Running   0            8h    192.168.250.9    node4   <none>           <none>
kube-proxy-ggbqh                          1/1     Running   0            8h    192.168.250.19   node2   <none>           <none>
kube-proxy-kngkd                          1/1     Running   0            8h    192.168.250.10   cp1     <none>           <none>
kube-proxy-ph72w                          1/1     Running   0            8h    192.168.250.25   node1   <none>           <none>
kube-proxy-zmm62                          1/1     Running   0            8h    192.168.250.37   node3   <none>           <none>
kube-scheduler-cp1                        1/1     Running   2 (9h ago)   9h    192.168.250.10   cp1     <none>           <none>
nginx-proxy-node1                         1/1     Running   0            9h    192.168.250.25   node1   <none>           <none>
nginx-proxy-node2                         1/1     Running   0            9h    192.168.250.19   node2   <none>           <none>
nginx-proxy-node3                         1/1     Running   0            9h    192.168.250.37   node3   <none>           <none>
nginx-proxy-node4                         1/1     Running   0            9h    192.168.250.9    node4   <none>           <none>
nodelocaldns-96sjv                        1/1     Running   0            9h    192.168.250.37   node3   <none>           <none>
nodelocaldns-9pthr                        1/1     Running   0            9h    192.168.250.10   cp1     <none>           <none>
nodelocaldns-btq6j                        1/1     Running   0            9h    192.168.250.19   node2   <none>           <none>
nodelocaldns-rkbdd                        1/1     Running   0            9h    192.168.250.25   node1   <none>           <none>
nodelocaldns-s5ph7                        1/1     Running   0            9h    192.168.250.9    node4   <none>           <none>
```

## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

## Ответ: 

Для данного задания было решено выполнить развертывание в домашней виртуальной среде ProxmoxVE с помощью kubeadm c CNI flannel.

Адресация виртуальных машин: 192.168.8.30, 192.168.8.31, 192.168.8.32. 

Подготовка всех виртульных машин выполнялась по одной схеме, а именно:

Добавление модулей и опций ядра:
```
dgolodnikov@pve-kube-cp1:~$ echo "br_netfilter" | sudo tee -a /etc/modules
dgolodnikov@pve-kube-cp1:~$ echo "overlay" | sudo tee -a /etc/modules
dgolodnikov@pve-kube-cp1:~$ echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
dgolodnikov@pve-kube-cp1:~$ echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
dgolodnikov@pve-kube-cp1:~$ echo "net.bridge.bridge-nf-call-arptables=1" | sudo tee -a /etc/sysctl.conf
dgolodnikov@pve-kube-cp1:~$ echo "net.bridge.bridge-nf-call-ip6tables=1" | sudo tee -a /etc/sysctl.conf

dgolodnikov@pve-kube-cp1:~$ cat /etc/modules
# a bit deleted 
br_netfilter
overlay

dgolodnikov@pve-kube-cp1:~$ cat /etc/sysctl.conf
# a bit deleted 
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-arptables=1
net.bridge.bridge-nf-call-ip6tables=1
```

Отключение swap (без отключения не стартует kubelet) через комментирование строки в /etc/fstab:
```
dgolodnikov@pve-kube-cp1:~$ cat /etc/fstab
# a bit deleted
#/swap.img      none    swap    sw      0       0
```

Корректировка файла /etc/hosts:
```
dgolodnikov@pve-kube-cp1:~$ cat /etc/hosts
# a bit deleted
127.0.1.1 pve-kube-cp1
192.168.8.30 pve-kube-cp1
```

Корректировка файла /etc/hostname:
```
dgolodnikov@pve-kube-cp1:~$ cat /etc/hostname
pve-kube-cp1
```
Выполняем ребут ВМ (можно обойтись без reboot выполвнив команды `sudo sysctl -p /etc/sysctl.conf && sudo swapoff -a`):
```
sudo reboot
```
Подготовка к установке кластера:
```
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl containerd
sudo apt-mark hold kubelet kubeadm kubectl
```
Создаем дефолт конфигурации containerd и перезапускаем сервис:
```
sudo -- sh -c "containerd config default | tee /etc/containerd/config.toml"
sudo systemctl restart containerd.service
```

Запускаем установку для мастер ноды (только для controlplane node):

```
dgolodnikov@pve-kube-cp1:~$ sudo kubeadm init   --apiserver-advertise-address=192.168.8.30   --pod-network-cidr 10.244.0.0/16   --apiserver-cert-extra-sans=MY_PUBLIC_IP
```
Настраиваем kubectl (только для controlplane node):
```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Проверяем:
```
dgolodnikov@pve-kube-cp1:~$ kubectl get nodes
NAME           STATUS     ROLES           AGE   VERSION
pve-kube-cp1   NotReady   control-plane   74s   v1.25.4
```
Устанавливаем сетевой плагин (только для controlplane node)

```
dgolodnikov@pve-kube-cp1:~$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
namespace/kube-flannel created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created
```
Проверяем, мастер нода Ready:

```
dgolodnikov@pve-kube-cp1:~$ kubectl get nodes
NAME           STATUS   ROLES           AGE     VERSION
pve-kube-cp1   Ready    control-plane   3m44s   v1.25.4
```
Для настройки рабочих нод необходимо создать токен на мастере: 
```
kubeadm token create --print-join-command
kubeadm join 192.168.8.30:6443 --token j1fpu8.n9wna1cgpd98dxio \
        --discovery-token-ca-cert-hash sha256:251edbd9fa258679ec91a38f35cf6482a48437041e225519084f19d5f4d11eda
```
На рабочих нодах запускаем (только для workernode):
```
sudo kubeadm join 192.168.8.30:6443 --token n3knr7.pixtgfppw1mr1p7e --discovery-token-ca-cert-hash sha256:e01d39cc353485c09e4476232e4cfce582fe4c0f9fef78c82c1eff8f69b22e25
```

Проверяем на control node:
```
dgolodnikov@pve-kube-cp1:~$ kubectl get nodes
NAME             STATUS   ROLES           AGE   VERSION
pve-kube-cp1     Ready    control-plane   22h   v1.25.4
pve-kube-node1   Ready    <none>          65s   v1.25.4
pve-kube-node2   Ready    <none>          38s   v1.25.4

dgolodnikov@pve-kube-cp1:~$ kubectl get pods --all-namespaces -o wide
NAMESPACE      NAME                                   READY   STATUS    RESTARTS      AGE    IP             NODE             NOMINATED NODE   READINESS GATES
kube-flannel   kube-flannel-ds-fdxhb                  1/1     Running   1 (21h ago)   22h    192.168.8.30   pve-kube-cp1     <none>           <none>
kube-flannel   kube-flannel-ds-zcrdr                  1/1     Running   0             110s   192.168.8.31   pve-kube-node1   <none>           <none>
kube-flannel   kube-flannel-ds-zpwgs                  1/1     Running   0             83s    192.168.8.32   pve-kube-node2   <none>           <none>
kube-system    coredns-565d847f94-82tww               1/1     Running   1 (21h ago)   22h    10.244.0.4     pve-kube-cp1     <none>           <none>
kube-system    coredns-565d847f94-ch7rb               1/1     Running   1 (21h ago)   22h    10.244.0.5     pve-kube-cp1     <none>           <none>
kube-system    etcd-pve-kube-cp1                      1/1     Running   1 (21h ago)   22h    192.168.8.30   pve-kube-cp1     <none>           <none>
kube-system    kube-apiserver-pve-kube-cp1            1/1     Running   1 (21h ago)   22h    192.168.8.30   pve-kube-cp1     <none>           <none>
kube-system    kube-controller-manager-pve-kube-cp1   1/1     Running   1 (21h ago)   22h    192.168.8.30   pve-kube-cp1     <none>           <none>
kube-system    kube-proxy-67h2s                       1/1     Running   0             83s    192.168.8.32   pve-kube-node2   <none>           <none>
kube-system    kube-proxy-bk27z                       1/1     Running   1 (21h ago)   22h    192.168.8.30   pve-kube-cp1     <none>           <none>
kube-system    kube-proxy-sd2lj                       1/1     Running   0             110s   192.168.8.31   pve-kube-node1   <none>           <none>
kube-system    kube-scheduler-pve-kube-cp1            1/1     Running   1 (21h ago)   22h    192.168.8.30   pve-kube-cp1     <none>           <none>
```
PS: 
Пока нет понимания как делать кластер из несколько ControlPlane node.
Предполагаю решение крайне сложно в траблшутинге в случае проблем, в том числе сетевых. Пока сложно представляется этот процесс, кроме как посмотреть логи и пойти в Гугл.