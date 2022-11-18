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

## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

## ОТВЕТ на задание 3

```
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

















