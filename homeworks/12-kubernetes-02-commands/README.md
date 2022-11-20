# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods

## ОТВЕТ на задание 1:

```
vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-01-intro$ kubectl create deployment hello-k8s --image=hello-k8s:1.0.0 --port=8080 --replicas=2
deployment.apps/hello-k8s created

vagrant@server3:~$ kubectl get deployments
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
hello-k8s   2/2     2            2           3m31s

vagrant@server3:~$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
busybox                      1/1     Running   0          8h
hello-k8s-775d494f74-fr7g4   1/1     Running   0          3m50s
hello-k8s-775d494f74-rnndc   1/1     Running   0          3m50s

```

## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

## ОТВЕТ на задание 2

Создаем новый namespace app-namespace согласно задания:
```
vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-02-commands$ kubectl create namespace app-namespace
namespace/app-namespace created
```
Создаем тестовый deployment в новом namespace (используем образ из предидущего задания):
```
kubectl create deployment hello-k8s --image=hello-k8s:1.0.0 --port=8080 --replicas=2 -n app-namespace
deployment.apps/hello-k8s created
```

Создаем дополнительный сервисный аккаунт (yoda) в нужном namespace (app-namespace):
```
vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-02-commands$ kubectl create serviceaccount yoda --namespace app-namespace serviceaccount/yoda created

vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-02-commands$ kubectl get serviceaccount --all-namespaces
NAMESPACE              NAME                                 SECRETS   AGE
app-namespace          default                              0         4m14s
app-namespace          yoda                                 0         2m20s

vagrant@server3:~/REPO/devops-netology/homeworks/12-kubernetes-02-commands$ kubectl get serviceaccounts yoda --namespace=app-namespace -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-11-19T18:18:33Z"
  name: yoda
  namespace: app-namespace
  resourceVersion: "87916"
  uid: b8c1702e-3eae-4004-acf6-9562de3ff49a
```

Создаем токен доступа для сервисного аккаунта для доступа к API:
```
vagrant@server3:/var/run$  kubectl create token yoda --namespace app-namespace
eyJhbGciOiXXXXXXXXXXXXXXXXXXXX1N3aUN4
```

Создаем отдельный конфигурационный файл для данного пользователя (его можно будет в перспективе передать разработчикам, файл config-for-dev), но перед этим узнаем certificate-authority-data.

```
vagrant@server3:~$ kubectl config view --flatten -o yaml | grep  certificate-authority-data
    certificate-authority-data: LS0tLSXXXXXXXXXXXXXXXXXXXXXXRS0tLS0tCg==
```

Создаем config-for-dev:
```yaml
vagrant@server3:~/.kube$ cat config-for-dev
apiVersion: v1
kind: Config
users:
- name: yoda
  user:
    token: eyJhbGciOiXXXXXXXXXXXXXXXXXXXX1N3aUN4
clusters:
- cluster:
    certificate-authority-data: LS0tLSXXXXXXXXXXXXXXXXXXXXXXRS0tLS0tCg==
    server: https://192.168.49.2:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: yoda
  name: yoda-context
current-context: yoda-context
```
Также требуется создать Role и прикрутить ее к ServiceAccounts через RoleBindings. Применение конфигурации через `kubectl apply -f <file> --namespace=app-namespace`:

```yaml
vagrant@server3:~/.kube$ cat app-namespace-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: app-namespace
  name: RN-for-yoda
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "describe"]
```
```yaml
vagrant@server3:~/.kube$ cat app-namespace-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: yoda-RN-for-yoda-rolebinding
  namespace: app-namespace
subjects:
- kind: User
  name: system:serviceaccount:app-namespace:yoda # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: RN-for-yoda # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```
Проверям для разрешенной и запрещенной команды:
```
vagrant@server3:~/.minikube/profiles$ kubectl --kubeconfig=/home/vagrant/.kube/config-for-dev get pods
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:app-namespace:yoda" cannot list resource "pods" in API group "" in the namespace "default"

kubectl --kubeconfig=/home/vagrant/.kube/config-for-dev describe pod hello-k8s-775d494f74-d68v6 --namespace=app-namespace
Name:             hello-k8s-775d494f74-d68v6
Namespace:        app-namespace
Priority:         0
Service Account:  default
...
Events:                      <none>

```

Конфигурационный файлы также приведены в данном репозитории:
[Конфигурация для админа куберкластера config](config)

[Конфигурация для разработчиков config-for-dev](config-for-dev)

[Конфигурация Role app-namespace-role](app-namespace-role.yaml)

[Конфигурация RoleBindings app-namespace-rolebinding](app-namespace-rolebinding.yaml)

## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

## ОТВЕТ на задание 3

```sh
vagrant@server3:~$ kubectl scale deployments hello-k8s --replicas=5
deployment.apps/hello-k8s scaled

vagrant@server3:~$ kubectl get pods
NAME                         READY   STATUS              RESTARTS   AGE
busybox                      1/1     Running             0          8h
hello-k8s-775d494f74-fr7g4   1/1     Running             0          4m59s
hello-k8s-775d494f74-jbp9c   0/1     ContainerCreating   0          3s
hello-k8s-775d494f74-jn7l2   0/1     ContainerCreating   0          3s
hello-k8s-775d494f74-lk25j   0/1     ContainerCreating   0          3s

vagrant@server3:~$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
busybox                      1/1     Running   0          8h
hello-k8s-775d494f74-fr7g4   1/1     Running   0          5m4s
hello-k8s-775d494f74-jbp9c   1/1     Running   0          8s
hello-k8s-775d494f74-jn7l2   1/1     Running   0          8s
hello-k8s-775d494f74-lk25j   1/1     Running   0          8s
hello-k8s-775d494f74-rnndc   1/1     Running   0          5m4s
```

















