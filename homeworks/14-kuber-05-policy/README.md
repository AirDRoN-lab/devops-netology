# Домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Создайте модуль

```
kubectl apply -f 14.5/example-security-context.yml
```

Проверьте установленные настройки внутри контейнера

```
kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```



## Ответ: 

В манифесте раскоментирована строка `command: [ "sh", "-c", "sleep 1h" ]` для того, чтобы контейнер не падал (в противном случае статус `CrashLoopBackOff`, хотя в этом ничего тсрашного в нашем случае и нет).

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl apply -f example-security-context.yml
pod/security-context-demo created

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
security-context-demo   1/1     Running   0          4m8s
```
Проверяем id пользователя, id группы c которым запустился контейнер:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl exec -it security-context-demo -- id
uid=1000 gid=3000 groups=3000
```
Все совпадает с указанием в манифесте:
```
   securityContext:
      runAsUser: 1000
      runAsGroup: 3000
```
Все ок.

## Задача 2 (*): Рассмотрите пример 14.5/example-network-policy.yml

Создайте два модуля. Для первого модуля разрешите доступ к внешнему миру
и ко второму контейнеру. Для второго модуля разрешите связь только с
первым контейнером. Проверьте корректность настроек.

## Ответ:

Т.к. использование NetworkPolicy подразумевает соответствующий CNI, переключаемся на кластер с CNI Calico.

```
dgolodnikov@pve-vm1:~$ kubectl config use-contexts kuberc

dgolodnikov@pve-vm1:~$ kubectl config get-contexts
CURRENT   NAME     CLUSTER         AUTHINFO       NAMESPACE
*         kuberc   kuber-calico    dgolodnikov2
          kuberf   kuber-flannel   dgolodnikov1

dgolodnikov@pve-vm1:~$ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   26d   v1.24.4
node2   Ready    <none>          26d   v1.24.4
node3   Ready    <none>          26d   v1.24.4
```
Воспользуемся репозиторием [gitlab.com/k11s-os/k8s-lessons/-/tree/main/NetworkPolicy](https://gitlab.com/k11s-os/k8s-lessons/-/tree/main/NetworkPolicy)

Создадим namespace и назначим метки:
```
dgolodnikov@pve-vm1:~$ kubectl create ns team-a
namespace/team-a created
dgolodnikov@pve-vm1:~$ kubectl create ns team-b
namespace/team-b created
dgolodnikov@pve-vm1:~$ kubectl label namespace team-a app=team-a
namespace/team-a labeled
dgolodnikov@pve-vm1:~$ kubectl label namespace team-b app=team-b
namespace/team-b labeled
```
Создадим манифест приложения [10-app.yaml](manifests/10-app.yaml) и применим (изменен тип с ClusterIP на NodePort для тестирования снаружи):

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl apply -f 10-app.yaml
pod/ta created
service/ta created
pod/tb created
service/tb created

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl get pods --all-namespaces | grep team
team-a        ta                                        1/1     Running   0             3m12s
team-b        tb                                        1/1     Running   0             3m12s
```

Проверяем сетевую связность и сервис (вывод ниже сокращен):

```
dgolodnikov@pve-vm1:~$ kubectl exec -it ta -n team-a -- curl tb.team-b
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>

dgolodnikov@pve-vm1:~$ kubectl exec -it ta -n team-a -- curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>

dgolodnikov@pve-vm1:~$ kubectl exec -it tb -n team-b -- curl ta.team-a
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
....
</html>

dgolodnikov@pve-vm1:~$ kubectl exec -it tb -n team-b -- curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

Снаружи они также доступны:
```
dgolodnikov@pve-vm1:~$ curl 192.168.8.40:30002
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>

dgolodnikov@pve-vm1:~$ curl 192.168.8.40:30001
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

Запретим `ta` выход в интернет, манифест [manifests/20-netpolicy01.yaml](manifests/20-netpolicy01.yaml) или [manifests/30-netpolicy02.yaml](manifests/30-netpolicy02.yaml) или [manifests/40-netpolicy03.yaml](manifests/40-netpolicy03.yaml).
Три манифеста дают одинаковый эффект (в части ограничения выхода в Интернет). В первом случае разрешен трафик только в серую подсеть 192.168.0.0/16 и 10/8, во втором случае у нас разрешен трафик только к конкретному неймспейсу c метками `team-b`, а третий вариант дополниьельно проверяет еще и метку пода, она должна быть `tb`. В противном случае доступа не будет (по tcp/80).

```
dgolodnikov@pve-vm1:~$ kubectl exec -it -n team-a ta -- bash
root@ta:/# curl google.com
^C
```

Что касается пода a в namespase `team-а`, то там разреш полностью любой трафик, т.к. нет ни одной политики затрагивающей под (а по дефолту default to allow). Создадим манифест разрешающий только трафик с пода `tb` неймспейса `team-b`. Манифест [manifests/50-netpolicy04.yaml](manifests/50-netpolicy04.yaml).
Применим магифест и проверим доступ снаружи к поду `tb` (namespace team-b).

```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl apply -f 50-netpolicy04.yaml 
networkpolicy.networking.k8s.io/team-a-egress configured
networkpolicy.networking.k8s.io/team-b-ingress created
```

Изнутри кластера (из пода `ta`) доступ к поду `tb` есть:
```
root@ta:/# curl tb.team-b
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>

</html>
```

Снаружи доступа нет:
```
dgolodnikov@pve-vm1:~$ kubectl get svc -n team-b
NAME   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
tb     NodePort   10.233.40.94   <none>        80:30002/TCP   4h30m
root@ta:/# exit

dgolodnikov@pve-vm1:~$ curl 192.168.8.40:30002
^C
```

Соответсввенно, `team-b.tb` и `team-a.ta` могут общаться только между собой внутри кластера (причем по DNS имени в том числе). При этом у `team-b.tb` есть выход в Интернет, а у `team-a` нет. Что и требовалось в задании. 


PS:
В доп. задании странно отработал раскоментированный блок в манифесте [manifests/21-netpolicy01_test.yaml](manifests/21-netpolicy01_test.yaml). Отличие от рабочего [manifests/20-netpolicy01.yaml](manifests/20-netpolicy01.yaml) заключается в раскоментированном блоке:

```
    # - namespaceSelector:
    #     matchLabels:
    #       name: kube-system 
```
По отступам, насколько позволяет опыт, проблем не увидел. Namespace существует. Доступа к DNS нет, причина выесняется.

Применили проблемный манифест [manifests/21-netpolicy01_test.yaml](manifests/21-netpolicy01_test.yaml).
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl apply -f 21-netpolicy01_test.yaml 
networkpolicy.networking.k8s.io/team-a-egress configured
```

Доступа к DNS нет:
```
root@ta:/# nslookup ngs.ru
Server:         169.254.25.10
Address:        169.254.25.10#53

Non-authoritative answer:
Name:   ngs.ru
Address: 195.19.220.25

root@ta:/# nslookup ngs.ru
;; connection timed out; no servers could be reached
```

Применили рабочий манифест [manifests/20-netpolicy01_test.yaml](manifests/20-netpolicy01.yaml).
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/14-kuber-05-policy/manifests$ kubectl apply -f 21-netpolicy01_test.yaml 
networkpolicy.networking.k8s.io/team-a-egress configured
```
Резолв домена есть
```
root@ta:/# nslookup ngs.ru
Server:         169.254.25.10
Address:        169.254.25.10#53

Non-authoritative answer:
Name:   ngs.ru
Address: 195.19.220.25
```
Причина пока не понятна. Ниже описание текущего кластера. 

```
dgolodnikov@pve-vm1:~$ kubectl get namespaces --show-labels
NAME              STATUS   AGE     LABELS
default           Active   26d     kubernetes.io/metadata.name=default
kube-node-lease   Active   26d     kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   26d     kubernetes.io/metadata.name=kube-public
kube-system       Active   26d     kubernetes.io/metadata.name=kube-system
team-a            Active   4h47m   app=team-a,kubernetes.io/metadata.name=team-a
team-b            Active   4h47m   app=team-b,kubernetes.io/metadata.name=team-b
```
```
dgolodnikov@pve-vm1:~$ kubectl get pods -n kube-system --show-labels
NAME                                      READY   STATUS    RESTARTS       AGE   LABELS
calico-kube-controllers-d6484b75c-wzql2   1/1     Running   4 (12d ago)    26d   k8s-app=calico-kube-controllers,pod-template-hash=d6484b75c
calico-node-2nsmh                         1/1     Running   3 (6h9m ago)   26d   controller-revision-hash=7b99df8b86,k8s-app=calico-node,pod-template-generation=1
calico-node-l765z                         1/1     Running   3 (12d ago)    26d   controller-revision-hash=7b99df8b86,k8s-app=calico-node,pod-template-generation=1
calico-node-qdlbk                         1/1     Running   3 (6h9m ago)   26d   controller-revision-hash=7b99df8b86,k8s-app=calico-node,pod-template-generation=1
coredns-588bb58b94-gtmrw                  1/1     Running   3 (6h9m ago)   26d   k8s-app=kube-dns,pod-template-hash=588bb58b94
coredns-588bb58b94-jjtbp                  1/1     Running   3 (6h9m ago)   26d   k8s-app=kube-dns,pod-template-hash=588bb58b94
dns-autoscaler-5b9959d7fc-662hq           1/1     Running   3 (6h9m ago)   26d   k8s-app=dns-autoscaler,pod-template-hash=5b9959d7fc
kube-apiserver-cp1                        1/1     Running   4 (6h9m ago)   26d   component=kube-apiserver,tier=control-plane
kube-controller-manager-cp1               1/1     Running   4 (6h9m ago)   26d   component=kube-controller-manager,tier=control-plane
kube-proxy-c49t2                          1/1     Running   3 (6h9m ago)   26d   controller-revision-hash=86459f8b99,k8s-app=kube-proxy,pod-template-generation=1
kube-proxy-jwbhz                          1/1     Running   3 (6h9m ago)   26d   controller-revision-hash=86459f8b99,k8s-app=kube-proxy,pod-template-generation=1
kube-proxy-nz7mp                          1/1     Running   3 (6h9m ago)   26d   controller-revision-hash=86459f8b99,k8s-app=kube-proxy,pod-template-generation=1
kube-scheduler-cp1                        1/1     Running   4 (6h9m ago)   26d   component=kube-scheduler,tier=control-plane
nginx-proxy-node2                         1/1     Running   3 (12d ago)    26d   addonmanager.kubernetes.io/mode=Reconcile,k8s-app=kube-nginx
nginx-proxy-node3                         1/1     Running   3 (6h9m ago)   26d   addonmanager.kubernetes.io/mode=Reconcile,k8s-app=kube-nginx
nodelocaldns-2ncc6                        1/1     Running   5 (6h9m ago)   26d   controller-revision-hash=744f664d5c,k8s-app=nodelocaldns,pod-template-generation=1
nodelocaldns-k2rx8                        1/1     Running   3 (6h9m ago)   26d   controller-revision-hash=744f664d5c,k8s-app=nodelocaldns,pod-template-generation=1
nodelocaldns-pkgx8                        1/1     Running   3 (6h9m ago)   26d   controller-revision-hash=744f664d5c,k8s-app=nodelocaldns,pod-template-generation=1

```
 

