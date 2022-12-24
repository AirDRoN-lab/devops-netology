
# Домашнее задание к занятию "13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet"
В работе часто приходится применять системы автоматической генерации конфигураций. Для изучения нюансов использования разных инструментов нужно попробовать упаковать приложение каждым из них.

## Задание 1: подготовить helm чарт для приложения
Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:
* каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;
* в переменных чарта измените образ приложения для изменения версии.


## Ответ

Helm чарт подготовлен, выложен  здесь: [testapp](testapp/) 

Дефолт значения переменных чарта:

```
replicaCount: 1
namespace: default

nameOverride: ""
fullnameOverride: ""

metadata:
  labels:
    appfront: frontend-web
    appback: beckend-web
    appdbweb: main-db

FrontPort: 30100
BackPort: 30001
```

## Задание 2: запустить 2 версии в разных неймспейсах
Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:
* одну версию в namespace=app1;
* вторую версию в том же неймспейсе;
* третью версию в namespace=app2.

## Ответ

Тестирование чарта. При инсталляции чарта необходимо через параметры запуска (--set) изменять порты фронтенда и бекенда (в противном случае сервис не будет создан, по причине занятого порта), а также namespace. Используем ключ `--create-namespace` для создания namespace, если он не создан.   

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-04-helm$ helm install --namespace app1 --set namespace=app1 --create-namespace dev01 testapp/
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/dgolodnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/dgolodnikov/.kube/config
NAME: dev01
LAST DEPLOYED: Sat Dec 24 18:14:12 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
---------------------------------------------------------

Deployed version 1.0.0. Release name: dev01
---------------------------------------------------------

  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app1 port-forward $POD_NAME 8080:$CONTAINER_PORT
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-04-helm$ helm install --namespace app1 --set namespace=app1 --set FrontPort=30101 --set BackPort=30002 --create-namespace dev02 testapp/
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/dgolodnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/dgolodnikov/.kube/config
NAME: dev02
LAST DEPLOYED: Sat Dec 24 18:14:53 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
---------------------------------------------------------

Deployed version 1.0.0. Release name: dev02
---------------------------------------------------------

  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app1 port-forward $POD_NAME 8080:$CONTAINER_PORT
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-04-helm$ helm install --namespace app2 --set namespace=app2 --set FrontPort=30102 --set BackPort=30003 --create-namespace dev03 testapp/
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/dgolodnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/dgolodnikov/.kube/config
NAME: dev03
LAST DEPLOYED: Sat Dec 24 18:15:18 2022
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
---------------------------------------------------------

Deployed version 1.0.0. Release name: dev03
---------------------------------------------------------

  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app2 port-forward $POD_NAME 8080:$CONTAINER_PORT

```
Смотрим первый nammespace app1
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-04-helm$ kubectl get all -n app1
NAME                                       READY   STATUS    RESTARTS   AGE
pod/dev01-testapp-back-5448f98667-9gflp    1/1     Running   0          2m43s
pod/dev01-testapp-db-0                     1/1     Running   0          2m43s
pod/dev01-testapp-front-54d66cf546-r8swr   1/1     Running   0          2m43s
pod/dev02-testapp-back-666765bb4b-d4mmz    1/1     Running   0          2m2s
pod/dev02-testapp-db-0                     1/1     Running   0          2m2s
pod/dev02-testapp-front-79d8564c-s4g4h     1/1     Running   0          2m2s

NAME                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/dev01-testapp-back-svc    NodePort    10.97.212.110    <none>        9000:30001/TCP   2m43s
service/dev01-testapp-db-svc      ClusterIP   10.102.48.236    <none>        5432/TCP         2m43s
service/dev01-testapp-front-svc   NodePort    10.110.69.36     <none>        80:30100/TCP     2m43s
service/dev02-testapp-back-svc    NodePort    10.110.127.206   <none>        9000:30002/TCP   2m2s
service/dev02-testapp-db-svc      ClusterIP   10.105.38.239    <none>        5432/TCP         2m2s
service/dev02-testapp-front-svc   NodePort    10.109.179.234   <none>        80:30101/TCP     2m2s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dev01-testapp-back    1/1     1            1           2m43s
deployment.apps/dev01-testapp-front   1/1     1            1           2m43s
deployment.apps/dev02-testapp-back    1/1     1            1           2m2s
deployment.apps/dev02-testapp-front   1/1     1            1           2m2s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/dev01-testapp-back-5448f98667    1         1         1       2m43s
replicaset.apps/dev01-testapp-front-54d66cf546   1         1         1       2m43s
replicaset.apps/dev02-testapp-back-666765bb4b    1         1         1       2m2s
replicaset.apps/dev02-testapp-front-79d8564c     1         1         1       2m2s

NAME                                READY   AGE
statefulset.apps/dev01-testapp-db   1/1     2m43s
statefulset.apps/dev02-testapp-db   1/1     2m2s

```

Смотрим второй namespace app2
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-04-helm$ kubectl get all -n app2
NAME                                       READY   STATUS    RESTARTS   AGE
pod/dev03-testapp-back-d494666c7-rfxth     1/1     Running   0          2m9s
pod/dev03-testapp-db-0                     1/1     Running   0          2m9s
pod/dev03-testapp-front-5fd8957dc6-7cpcp   1/1     Running   0          2m9s

NAME                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/dev03-testapp-back-svc    NodePort    10.101.189.56    <none>        9000:30003/TCP   2m9s
service/dev03-testapp-db-svc      ClusterIP   10.107.170.83    <none>        5432/TCP         2m9s
service/dev03-testapp-front-svc   NodePort    10.111.165.148   <none>        80:30102/TCP     2m9s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dev03-testapp-back    1/1     1            1           2m9s
deployment.apps/dev03-testapp-front   1/1     1            1           2m9s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/dev03-testapp-back-d494666c7     1         1         1       2m9s
replicaset.apps/dev03-testapp-front-5fd8957dc6   1         1         1       2m9s

NAME                                READY   AGE
statefulset.apps/dev03-testapp-db   1/1     2m9s

```

Смотрим pv:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-04-helm$ kubectl get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                     STORAGECLASS   REASON   AGE
dev01-pv   10Gi       RWO            Retain           Bound    app1/dev01-pvc-postgres                           7m52s
dev02-pv   10Gi       RWO            Retain           Bound    app1/dev02-pvc-postgres                           7m11s
dev03-pv   10Gi       RWO            Retain           Bound    app2/dev03-pvc-postgres                           6m45s

```

Смотрим pvc:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-04-helm$ kubectl get pvc -n app1
NAME                 STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
dev01-pvc-postgres   Bound    dev01-pv   10Gi       RWO                           8m35s
dev02-pvc-postgres   Bound    dev02-pv   10Gi       RWO                           7m54s
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-04-helm$ kubectl get pvc -n app2
NAME                 STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
dev03-pvc-postgres   Bound    dev03-pv   10Gi       RWO                           7m30s
```

Для проверки сервиса зайдем на все три сервиса по очереди через веб браузер, ниже приведены скриншоты:<br>
[dev01_app1_192.168.8.30:30100](dev01_app1_screen.PNG)<br>
[dev02_app1_192.168.8.30:30101](dev02_app1_screen.PNG)<br>
[dev03_app2_192.168.8.30:30102](dev03_app2_screen.PNG)<br>

PS: если при запуске helm install выставить ключ --namespace, будет ли перезаписан namespace в манифестах?!









