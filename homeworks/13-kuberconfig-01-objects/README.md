# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

## Ответ 

Для старта задания необходимо особрать контейнеры frontend и backend. Для решения проблем в процессе сборки в Dockerfile фротнтенда были добавлены:
```
+ ENV NODE_OPTIONS=--openssl-legacy-provider
+ RUN npx browserslist@latest --update-db 
```
Также скорректированы переменные окружения для frontend, а именно `BASE_URL=http://backip:30001`.
backip был прописан на локальной машине в /etc/hosts. ПОрт 30001 был намеренно выбран из диапазона >30000, т.к. планировалось использовать Service NodePort для обеспечения доступа снаружи кластера.
Переменная окружения бд оставлена без изменений  `DATABASE_URL=postgres://postgres:postgres@db:5432/news`, но следует учитывать, что хостнейм db необходимо прописать, как сервис внутри кластера для обеспечения доступа к базе.

Собираем образы контейнеров:
```
dgolodnikov@pve-vm1:~$ docker build -t dgolodnikov/netobackend:1.0.0 .
dgolodnikov@pve-vm1:~$ docker build -t dgolodnikov/netofrontend:1.0.0 .
```
Выкладываем в репозиторий:
```
dgolodnikov@pve-vm1:~$ docker pull dgolodnikov/netofrontend:1.0.0
dgolodnikov@pve-vm1:~$ docker pull dgolodnikov/netobackend:1.0.0
```
Пишем манифесты для развертывания сервиса. Манифесты разделил на два файла service и pod/pvc/pv:<br>
[10-task1-service](manifests/10-task1_service.yaml)<br>
[20-task1-pods](manifests/20-task1_pods.yaml)<br>

Итого:
```
dgolodnikov@pve-vm1:~$ kubectl get pods -o wide
NAME                 READY   STATUS    RESTARTS   AGE   IP           NODE             NOMINATED NODE   READINESS GATES
db-0                 1/1     Running   0          87m   10.244.2.4   pve-kube-node2   <none>           <none>
web-d57c6f78-tjspt   2/2     Running   0          92m   10.244.1.3   pve-kube-node1   <none>           <none>
dgolodnikov@pve-vm1:~$ kubectl get endpoints
NAME         ENDPOINTS           AGE
back         10.244.1.3:9000     68m
db           10.244.2.4:5432     37m
front        10.244.1.3:80       68m
kubernetes   192.168.8.30:6443   17d
dgolodnikov@pve-vm1:~$ kubectl get svc -o wide
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE   SELECTOR
back         NodePort    10.109.212.56    <none>        9000:30001/TCP   68m   app=web
db           ClusterIP   10.111.141.160   <none>        5432/TCP         37m   app=db-web
front        NodePort    10.105.163.64    <none>        80:31266/TCP     68m   app=web
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP          17d   <none>
```

Скриншот обращения к БД для проверки бекенда:<br>
[Проверка связки бекенда и бд](task1_webscreen_db.PNG)<br>
Скриншот вывода фронтенда:<br>
[Проверка работоспособности сервиса, обращение к фронтенду](task1_webscreen.PNG)<br>


## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).

