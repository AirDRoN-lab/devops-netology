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

## Ответ

Немного перепишем манифесты так, как требуется в задании. Переменные окружения добавим в манифесты deployment. Сделаем два отельных деплоймента для фронтенда и для бекенда.<br>
[Манифест для подов](manifests/40-task2_pods.yaml)<br>
[Манифест для сервиса](manifests/30-task2_service.yaml)<br>

Проверям наличие переменных оуржения внутри контейнера после деплоя:
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-01-objects/manifests$ kubectl exec front-7fff466675-kt9dp -- printenv | grep BASE_URL
BASE_URL=http://backweb:30001

dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/13-kuberconfig-01-objects/manifests$ kubectl exec back-56849f497d-pt95n -- printenv | grep BASE
DATABASE_URL=postgres://postgres:postgres@dbweb:5432/news
```
Видим, что переменные окружения корректные. Значения соответсвуют прописанным в манифесте. Тем не менее, в случае с фронтендом мы получаем старую ссылку на бекенд "http://backip:30001" (т.е. из задания 1). Т.е. данная переменная не меняется, через переменные окружения, а зашита при сборке контейнера. 


## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).

## Ответ

Доступ к внешним сервисам можно сделать по домену через Service ExternalName, либо по IP через Service Cluster (без IP, Headless) c ссылкой на endpoint. Ради интереса сделаем оба варианта. В качестве API сервиса используем геокодер от Яндекса. В итоге:

```
apiVersion: v1
kind: Service
metadata: 
  name: geocode
spec:
  type: ClusterIP
  clusterIP: None
  externalName:
---
apiVersion: v1
kind: Service
metadata: 
  name: geocode-domain
spec:
  type: ExternalName
  externalName:  geocode-maps.yandex.ru
```
Добавим Endpoints, причем name должно совпадать (в нашем случае name: geocode).

```
apiVersion: v1
kind: Endpoints
metadata:
  name: geocode
subsets:
  - addresses:
    - ip:  213.180.193.58
    ports:
    - port: 80
```

Для проверки потербуется APIkey, его полчим через ЛК Yandex. 
Итоговые манифесты:<br>
[manifests/40-task2_pods.yaml](manifests/40-task2_pods.yaml)<br>
[manifests/50-task3_ep.yaml](manifests/50-task3_ep.yaml)<br>
[manifests/60-task3_service.yaml](manifests/60-task3_service.yaml)<br>

Проверку выполняем изнутри пода, два curl запроса. 
Проверка через Service External Name:
```
# curl -H "Host: geocode-maps.yandex.ru" "http://geocode/1.x/?apikey=89effe8c-c685-4943-baf2-db9acac2bc0b&geocode=37.597576,55.771899"
```
Проверка через Service Headless ClusterIP + Endpoints:
```
# curl -H "Host: geocode-maps.yandex.ru" "http://geocode-domain/1.x/?apikey=89effe8c-c685-4943-baf2-db9acac2bc0b&geocode=37.597576,55.771899"
```
Для проверки выполняем запрос из контейнера:
```
# curl -H "Host: geocode-maps.yandex.ru" "http://geocode-domain/1.x/?apikey=XXXXXXXXX-c685-4933-baf2-XXXXXXXX0b&geocode=37.597576,55.771899"
<?xml version="1.0" encoding="UTF-8"?><ymaps xmlns="http://maps.yandex.ru/ymaps/1.x" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/gml http://schemas.opengis.net/gml/3.1.1/base/gml.xsd http://maps.yandex.ru/ymaps/1.x https://maps.yandex.ru/schemas/ymaps/1.x/ymaps.xsd http://maps.yandex.ru/geocoder/1.x http://maps.yandex.ru/schemas/geocoder/1.x/geocoder.xsd http://maps.yandex.ru/address/1.x http://maps.yandex.ru/schemas/search/1.x/address.xsd urn:oasis:names:tc:ciq:xsdschema:xAL:2.0 http://docs.oasis-open.org/election/external/xAL.xsd"><GeoObjectCollection><metaDataProperty xmlns="http://www.opengis.net/gml"><GeocoderResponseMetaData xmlns="http://maps.yandex.ru/geocoder/1.x"><request>37.597576,55.771899</request><found>8</found><results>10</results><Point xmlns="http://www.opengis.net/gml"><pos>37.597576 55.771899</pos></Point></GeocoderResponseMetaData></metaDataProperty><featureMember xmlns="http://www.opengis.net/gml"><GeoObject xmlns="http://maps.yandex.ru/ymaps/1.x" xmlns:gml="http://www.opengis.net/gml" gml:id="1"><metaDataProperty xmlns="http://www.opengis.net/gml"><GeocoderMetaData xmlns="http://maps.yandex.ru/geocoder/1.x"><kind>house</kind><text>Россия, Москва, 4-я Тверская-Ямская улица, 7</text><precision>exact</precision><Address xmlns="http://maps.yandex.ru/address/1.x"><country_code>RU</country_code><postal_code>125047</postal_code><formatted>Россия, Москва, 4-я Тверская-Ямская улица, 7</formatted>
```
```
# curl -H "Host: geocode-maps.yandex.ru" "http://geocode/1.x/?apikey=XXXXXXXXXX-c685-4933-baf2-XXXXXXXXXXXX&geocode=37.597576,55.771899"
<?xml version="1.0" encoding="UTF-8"?><ymaps xmlns="http://maps.yandex.ru/ymaps/1.x" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/gml http://schemas.opengis.net/gml/3.1.1/base/gml.xsd http://maps.yandex.ru/ymaps/1.x https://maps.yandex.ru/schemas/ymaps/1.x/ymaps.xsd http://maps.yandex.ru/geocoder/1.x http://maps.yandex.ru/schemas/geocoder/1.x/geocoder.xsd http://maps.yandex.ru/address/1.x http://maps.yandex.ru/schemas/search/1.x/address.xsd urn:oasis:names:tc:ciq:xsdschema:xAL:2.0 http://docs.oasis-open.org/election/external/xAL.xsd"><GeoObjectCollection><metaDataProperty xmlns="http://www.opengis.net/gml"><GeocoderResponseMetaData xmlns="http://maps.yandex.ru/geocoder/1.x"><request>37.597576,55.771899</request><found>8</found><results>10</results><Point xmlns="http://www.opengis.net/gml"><pos>37.597576 55.771899</pos></Point></GeocoderResponseMetaData></metaDataProperty><featureMember xmlns="http://www.opengis.net/gml"><GeoObject xmlns="http://maps.yandex.ru/ymaps/1.x" xmlns:gml="http://www.opengis.net/gml" gml:id="1"><metaDataProperty xmlns="http://www.opengis.net/gml"><GeocoderMetaData xmlns="http://maps.yandex.ru/geocoder/1.x"><kind>house</kind><text>Россия, Москва, 4-я Тверская-Ямская улица, 7</text><precision>exact</precision><Address xmlns="http://maps.yandex.ru/address/1.x"><country_code>RU</country_code><postal_code>125047</postal_code><formatted>Россия, Москва, 4-я Тверская-Ямская улица, 7</formatted><
```
Ответ получен. Доступ к внешнему сервису получен через endpoint из пода внутри кластера. 
В сurl необходимо указать домен через ключ -H `-H "Host: geocode-maps.yandex.ru"` в противном сулчае в HTTP заголовок не помещается запись о реальном домене, а это в случае с данным сервисом необходимо.

## Состояние кластера после выполнения ДЗ

```sh
golodnikov@pve-vm1:~$ kubectl get nodes
NAME             STATUS   ROLES           AGE   VERSION
pve-kube-cp1     Ready    control-plane   19d   v1.25.4
pve-kube-node1   Ready    <none>          18d   v1.25.4
pve-kube-node2   Ready    <none>          18d   v1.25.4

dgolodnikov@pve-vm1:~$ kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE             NOMINATED NODE   READINESS GATES
back-56849f497d-pt95n    1/1     Running   0          22h   10.244.2.13   pve-kube-node2   <none>           <none>
dbweb-0                  1/1     Running   0          22h   10.244.1.7    pve-kube-node1   <none>           <none>
front-7fff466675-kt9dp   1/1     Running   0          22h   10.244.2.12   pve-kube-node2   <none>           <none>

dgolodnikov@pve-vm1:~$ kubectl get svc -o wide
NAME             TYPE           CLUSTER-IP       EXTERNAL-IP                     PORT(S)          AGE     SELECTOR
back             NodePort       10.107.203.132   <none>                          9000:30001/TCP   22h     app=backweb
dbweb            ClusterIP      10.102.32.68     <none>                          5432/TCP         22h     app=dbweb
front            NodePort       10.99.218.50     <none>                          80:30002/TCP     22h     app=frontweb
geocode          ClusterIP      None             <none>                          <none>           5h6m    <none>
geocode-domain   ExternalName   <none>           geocode-maps.yandex.ru          <none>           3h51m   <none>
kubernetes       ClusterIP      10.96.0.1        <none>                          443/TCP          22h     <none>
sandbox          ExternalName   <none>           api-sandbox.direct.yandex.com   <none>           4h24m   <none>

dgolodnikov@pve-vm1:~$ kubectl get endpoints -o wide
NAME         ENDPOINTS           AGE
back         10.244.2.13:9000    22h
dbweb        10.244.1.7:5432     22h
front        10.244.2.12:80      22h
geocode      213.180.193.58:80   3h51m
kubernetes   192.168.8.30:6443   22h

dgolodnikov@pve-vm1:~$ kubectl get statefulset -o wide
NAME    READY   AGE   CONTAINERS   IMAGES
dbweb   1/1     22h   postgres     postgres:13-alpine

dgolodnikov@pve-vm1:~$ kubectl get pvc -o wide
NAME           STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
pvc-postgres   Bound    pv       1Gi        RWO                           22h   Filesystem

dgolodnikov@pve-vm1:~$ kubectl get pv -o wide
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE   VOLUMEMODE
pv     1Gi        RWO            Retain           Bound    default/pvc-postgres                           22h   Filesystem

dgolodnikov@pve-vm1:~$ kubectl get deploy -o wide
NAME    READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                           SELECTOR
back    1/1     1            1           22h   backend      dgolodnikov/netobackend:1.0.0    app=backweb
front   1/1     1            1           22h   front        dgolodnikov/netofrontend:1.0.0   app=frontweb
```

PS: часто импользуемые команды <br>
kubectl get pods -o wide <br>
kubectl get endpoints <br>
kubectl get svc -o wide <br>
kubectl get pvc,pv <br>
kubectl get statefulset <br>
kubectl logs <pod_name> <br>
kubectl exec -it <pod_name> -- <command_name> <br>
 
