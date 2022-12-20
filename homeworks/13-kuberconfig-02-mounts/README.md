# Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

## Установка nfs-server/provisioner для задания 2

Воспользуемся инструкцией выше, поставим nfs-provisioner. В конце установки получили пример манифеста:

```
dgolodnikov@pve-vm1:~$ helm install nfs-server stable/nfs-server-provisioner
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/dgolodnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/dgolodnikov/.kube/config
WARNING: This chart is deprecated
NAME: nfs-server
LAST DEPLOYED: Sun Dec 18 17:05:10 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
```

Также на нодах неободимо поставить nfs-common, в противном случае можем записнуть на статусе создания пода:
```
dgolodnikov@pve-kube-node1:~$ sudo apt install nfs-common
```

## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

Подготовим манифест с тестовыми подами, пропишем pv и pvc:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-postgres 
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /data/pv
```

Итоговый манифест [manifests/40-task1_pods.yaml](manifests/40-task1_pods.yaml).
Выполянем и проверяем все ли корректно. Проверяем наличие папок и содержимое:

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c front -- ls -la / | grep static
drwxrwxrwx   2 root root 4096 Dec 20 05:06 static-front
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c backend -- ls -la / | grep static
drwxrwxrwx   2 root root 4096 Dec 20 05:06 static-back

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c front -- ls -la /static-front
total 8
drwxrwxrwx 2 root root 4096 Dec 20 05:06 .
drwxr-xr-x 1 root root 4096 Dec 20 05:06 ..

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c backend -- ls -la /static-back
total 8
drwxrwxrwx 2 root root 4096 Dec 20 05:06 .
drwxr-xr-x 1 root root 4096 Dec 20 05:06 ..
```
Создадим тестовый файл `mytestfile.txt` в конейнерае front и проверим его наличие в контейнере back. 

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c front -- touch /static-front/mytestfile.txt

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c front -- ls -la /static-front
total 8
drwxrwxrwx 2 root root 4096 Dec 20 05:17 .
drwxr-xr-x 1 root root 4096 Dec 20 05:06 ..
-rw-r--r-- 1 root root    0 Dec 20 05:17 mytestfile.txt

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c backend -- ls -la /static-back
total 8
drwxrwxrwx 2 root root 4096 Dec 20 05:17 .
drwxr-xr-x 1 root root 4096 Dec 20 05:06 ..
-rw-r--r-- 1 root root    0 Dec 20 05:17 mytestfile.txt
```
Как видим файл есть в обоих контейнерах. Проверим наличие файла на ноде, на которой запущен под:

```
dgolodnikov@pve-kube-node2:~$ sudo find /var/lib/kubelet -name mytestfile.txt
/var/lib/kubelet/pods/47920566-2f3a-44e0-ba38-5c4f555ff840/volumes/kubernetes.io~empty-dir/temp-volume/mytestfile.txt

dgolodnikov@pve-kube-node2:~$ mount | grep 47920566-2f3a-44e0-ba38-5c4f555ff840
tmpfs on /var/lib/kubelet/pods/47920566-2f3a-44e0-ba38-5c4f555ff840/volumes/kubernetes.io~projected/kube-api-access-rc8b9 type tmpfs (rw,relatime,size=2957396k)
```
Запишем текст в файл непосредственно на ноде и проверим внутри пода: 
```
dgolodnikov@pve-kube-node2:~$ echo "Preved medved!" | sudo tee /var/lib/kubelet/pods/47920566-2f3a-44e0-ba38-5c4f555ff840/volumes/kubernetes.io~empty-dir/temp-volume/mytestfile.txt
Preved medved!
```
```
dgolodnikov@pve-vm1:~/REPO$ kubectl get pods front-and-back-ff5c57d46-l75ns -o yaml | grep -A1 resourceVersion
  resourceVersion: "1148383"
  uid: 47920566-2f3a-44e0-ba38-5c4f555ff840

dgolodnikov@pve-vm1:~/REPO$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c backend -- cat /static-back/mytestfile.txt
Preved medved!

dgolodnikov@pve-vm1:~/REPO$ kubectl exec -it front-and-back-ff5c57d46-l75ns -c front -- cat /static-front/mytestfile.txt
Preved medved!
```
Все ок. Файл не пустой и виден из обоих контейнеров одного пода. Что и требовалось выполнить.


## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

## Ответ

Создадим два deployment манифеста, для развертывания фронтенда и бекенда (по аналогии с задачей 2 задания 13-1). Добавим pvc с StorageClass nfs:

```
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-vc-test
spec:
  storageClassName: "nfs"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Mi
```

Проверяем есть ли нужный StorageClass и доступные CSI после установки nfs-provisioner.
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl get sc
NAME   PROVISIONER                                       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs    cluster.local/nfs-server-nfs-server-provisioner   Delete          Immediate           true                   2d

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl get csinodes
NAME             DRIVERS   AGE
pve-kube-cp1     0         21d
pve-kube-node1   0         21d
pve-kube-node2   0         21d
```
Применияем итоговый манифест [manifests/60-task2_pods.yaml](manifests/60-task2_pods.yaml). Проверяем наличие pvc и его статус:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl get pvc -o wide
NAME              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
dynamic-vc-test   Bound    pvc-d53f5e8f-7680-43b6-bee0-c74109398641   100Mi      RWX            nfs            85s   Filesystem
pvc-postgres      Bound    pv                                         1Gi        RWO                           85s   Filesystem
```
Статус Bound, что и необходимо. Посмотрим подробнее о pvc, узнаим uid:

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl get pvc dynamic-vc-test -o yaml | grep uid
  uid: d53f5e8f-7680-43b6-bee0-c74109398641

dgolodnikov@pve-kube-node1:~$  mount | grep d53f5e8f-7680-43b6-bee0-c74109398641
10.103.15.5:/export/pvc-d53f5e8f-7680-43b6-bee0-c74109398641 on /var/lib/kubelet/pods/b30a155b-e578-4e66-90df-999e5c405e99/volumes/kubernetes.io~nfs/pvc-d53f5e8f-7680-43b6-bee0-c74109398641 type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.103.15.5,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=10.103.15.5)

dgolodnikov@pve-kube-node2:~$  mount | grep d53f5e8f-7680-43b6-bee0-c74109398641
10.103.15.5:/export/pvc-d53f5e8f-7680-43b6-bee0-c74109398641 on /var/lib/kubelet/pods/022bf1df-d251-42d0-8f9d-de0eb687bbb0/volumes/kubernetes.io~nfs/pvc-d53f5e8f-7680-43b6-bee0-c74109398641 type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.103.15.5,mountvers=3,mountport=20048,mountproto=tcp,local_lock=none,addr=10.103.15.5)
```
Создадим файл для проверки работоспособности nfs:

```
dgolodnikov@pve-vm1:~$ kubectl exec -it frontend-7fcbc8c84c-z499n -- ls -la /static-front
total 8
drwxrwsrwx 2 root root 4096 Dec 20 17:42 .
drwxr-xr-x 1 root root 4096 Dec 20 17:42 ..

dgolodnikov@pve-vm1:~$ kubectl exec -it back-866dcf4848-tf9pg -- ls -la /static-back
total 8
drwxrwsrwx 2 root root 4096 Dec 20 17:42 .
drwxr-xr-x 1 root root 4096 Dec 20 17:42 ..

dgolodnikov@pve-vm1:~$ kubectl exec -it frontend-7fcbc8c84c-z499n -- touch /static-front/kukushki.txt

dgolodnikov@pve-vm1:~$ kubectl exec -it frontend-7fcbc8c84c-z499n -- ls -la /static-front
total 8
drwxrwsrwx 2 root root 4096 Dec 20 17:47 .
drwxr-xr-x 1 root root 4096 Dec 20 17:42 ..
-rw-r--r-- 1 root root    0 Dec 20 17:47 kukushki.txt

dgolodnikov@pve-vm1:~$ kubectl exec -it back-866dcf4848-tf9pg -- ls -la /static-back
total 8
drwxrwsrwx 2 root root 4096 Dec 20 17:47 .
drwxr-xr-x 1 root root 4096 Dec 20 17:42 ..
-rw-r--r-- 1 root root    0 Dec 20 17:47 kukushki.txt
```
Посмотрим, что у нас творится на нодах и запишем в файл высокоинтеллектуальную строчку:
```
dgolodnikov@pve-kube-node1:~$ sudo find /var/lib/kubelet -name kukushki.txt
/var/lib/kubelet/pods/f7274349-5829-4111-a6bf-66d899eedc19/volumes/kubernetes.io~empty-dir/data/pvc-d53f5e8f-7680-43b6-bee0-c74109398641/kukushki.txt
/var/lib/kubelet/pods/b30a155b-e578-4e66-90df-999e5c405e99/volumes/kubernetes.io~nfs/pvc-d53f5e8f-7680-43b6-bee0-c74109398641/kukushki.txt

dgolodnikov@pve-kube-node2:~$ sudo find /var/lib/kubelet -name kukushki.txt
/var/lib/kubelet/pods/022bf1df-d251-42d0-8f9d-de0eb687bbb0/volumes/kubernetes.io~nfs/pvc-d53f5e8f-7680-43b6-bee0-c74109398641/kukushki.txt

dgolodnikov@pve-kube-node1:~$ echo "KUKU" | sudo tee /var/lib/kubelet/pods/b30a155b-e578-4e66-90df-999e5c405e99/volumes/kubernetes.io~nfs/pvc-d53f5e8f-7680-43b6-bee0-c74109398641/kukushki.txt
KUKU
```
Проверяем наличие строки в файлах изнутри подов:

```
dgolodnikov@pve-vm1:~$ kubectl exec -it frontend-7fcbc8c84c-z499n -- cat /static-front/kukushki.txt
KUKU

dgolodnikov@pve-vm1:~$ kubectl exec -it back-866dcf4848-tf9pg -- cat /static-back/kukushki.txt
KUKU
```
Все ок! Домашняя работа выполнена! 

PS: Описание PVC 

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl apply -f 10-pvcnfs.yaml
persistentvolumeclaim/dynamic-vc-test created
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-02-mounts/manifests$ kubectl describe pvc dynamic-vc-test
Name:          dynamic-vc-test
Namespace:     default
StorageClass:  nfs
Status:        Bound
Volume:        pvc-6423a2ca-c8f9-4137-9eca-1509bb3bd158
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: cluster.local/nfs-server-nfs-server-provisioner
               volume.kubernetes.io/storage-provisioner: cluster.local/nfs-server-nfs-server-provisioner
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      100Mi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason                 Age                From                                                                                                                      Message
  ----    ------                 ----               ----                                                                                                                      -------
  Normal  ExternalProvisioning   43s (x2 over 43s)  persistentvolume-controller                                                                                               waiting for a volume to be created, either by external provisioner "cluster.local/nfs-server-nfs-server-provisioner" or manually created by system administrator
  Normal  Provisioning           43s                cluster.local/nfs-server-nfs-server-provisioner_nfs-server-nfs-server-provisioner-0_8dd98f95-6452-4804-9770-490965d63963  External provisioner is provisioning volume for claim "default/dynamic-vc-test"
  Normal  ProvisioningSucceeded  43s                cluster.local/nfs-server-nfs-server-provisioner_nfs-server-nfs-server-provisioner-0_8dd98f95-6452-4804-9770-490965d63963  Successfully provisioned volume pvc-6423a2ca-c8f9-4137-9eca-1509bb3bd158
```