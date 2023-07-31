# Дипломный практикум в Yandex.Cloud
---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

## Введение

В данном репозитории находится копия проекта GitLab https://gitlab.com/dg-netology-diploma, соответсвенно ссылки ведут на GitLab
    
Выбор стека и архитектуры:

0. Git. Для хранения кода и версионирования используем коммерческий Gitlab (https://gitlab.com/).
В связи с тем что жизненный цикл инфраструктуры, эксплуатация кластера Kubernettes и непосредственно приложения слабо зависимы друг от друга и более того, обычно эксплуатируются разными командами, (по согласованию с руководителем) мы создадим три репозитория:

    Инфраструктура облачная `atlantis` (создание облачной инфраструктуры, а также изменение с помощью ATlantis).
    - https://gitlab.com/dg-netology-diploma/atlantis (копия https://github.com/AirDRoN-lab/devops-netology/tree/main/homeworks/00-diploma/atlantis)

    Инфраструктура Kubernetes `infras` (развертывания kuber кластера, мониторинг) 
    - https://gitlab.com/dg-netology-diploma/infras (копия https://github.com/AirDRoN-lab/devops-netology/tree/main/homeworks/00-diploma/infras)
    
    Сервисный `applicat` (сборка, тестирования и деплой приложения в kuber кластер)
    - https://gitlab.com/dg-netology-diploma/Applicat (копия https://github.com/AirDRoN-lab/devops-netology/tree/main/homeworks/00-diploma/applicat)

![00-projects_tree](source/images/00-projects_tree.png)

1. Container Registry. Для хранения образов приложения и вспомогательных контейнеров для GitlabCI используем docker hub (https://hub.docker.com/)  

    Реестр хранения приложения 
    - https://hub.docker.com/repository/docker/dgolodnikov/applicat/general
    
    Реестр хранение вспомогательных образов GitlabCI 
    - базовый (набор базового ПО: python3, python-pip, git, curl, wget, net-tools и т.д.) https://hub.docker.com/repository/docker/dgolodnikov/u2204_glimage_v1/general 
    - расширенный (включает базовый образ + предустановлен kubectl, helm, ansible и т.д.) https://hub.docker.com/repository/docker/dgolodnikov/u2204_glimage_v2/general


2. CICD. Для реализации процессов CICD как для деплоя приложения, так и для полного развертывания инфраструктуры и сервиса мониторинга используем CICD Gitlab. CICD процессы выполняются в динамических контейнерах на Share Gitlab runner-e, развернутый отдельно на домашней инфраструктуре на отдельной VM.

![Runner Gitlab](source/images/00-gitlab_runner.png)

3. Облако и инфраструктура.  В качестве сервиса облачной инфраструктуры используем Yandex облако, как наиболее доступное (есть грант). Инструмент удаленного развертывания инфраструктуры Terraform. Изменение облачной инфраструктуры с помощью  Atlantis поднятной на отдельной VM (в ручном режиме). Подготовку к развертыванию инфраструктуры (создание S3 для стейтов терраформ, создание серивисного аккаунта в Яндекс) в облаке будем выполнять используя CICD Gitlab (репозиторий https://gitlab.com/dg-netology-diploma/atlantis). При этом непосредственно создание облачной инфраструктуры можно сделать как с помощью Атлантис (требуется в ТЗ), так и с помощью Pipeline CICD Gitlab. Запуск Pipeline для удобства контроля сделан с ручным запуском. 

4. Уровень Kubernetes. Для деплоя приложений и их тестирования будем использовать кластер kubernettes. Деление сред будет выполнено посредством namespace, а именно: тестовая среда (test), продуктовая среда (prod) и среда мониторинга (monitoring).
Кластер состоит из трех node: однa control (cp1) и две compute (node01, node02).
Развертывание кластера будем выполнять через kubespray (заранее выполнен git clone репозитория https://github.com/kubernetes-sigs/kubespray для корректировки конфигурации) используя CICD Gitlab.

5. Уровень мониторинга Kubernetes. Деплой системы мониторинга выполняется в namespace monitoring kuber кластера. Для развертывания используется решение https://github.com/prometheus-operator/kube-prometheus (клонирование репозитория и настройка выполняется динамически на стадии CI). Запуск Pipeline для удобства контроля сделаем с ручным запуском. 

6. Уровень сервиса/приложения. Приложение будет из себя предоставлять базовый nginx контейнер (`nginx:alpine`) с динамически генерируемой тестовой страницей, содержащей короткий хеш коммита и tag (для обеспечения уникальности сборки и удобства проверки).
Сборку приложения будем выполнять внутри Gitlab Runner используя образ kaniko, т.к. позволяет собирать образы без установки docker. В силу отутствия требований к доступу приложения, доступ извне реализован через Service NodePort (хотя это не prodlike).
Установка и апгрейд приложения будет выполняться через helm для шаблонизации установки и удобного режима `upgrade` с ключом `--install`.

<BR> Исходные Variables для старта проекта (переменные прописаны в настройках общей группы Gitlab dg-netology-diploma и соответственно доступны всем трем проектам/репозиторим Gitlab, как `infras`и `applicat`, так и `atlantis`):

`DOCKER_REGISTRY` - URL реестра docker для хранения образов 

`DOCKER_REGISTRY_PASSWORD` - УЗ реестра docker (пароль)

`DOCKER_REGISTRY_USER` - УЗ реестра docker (логин)

`SSH_PRIVATE_KEY` - приватный SSH ключ для обеспечения доступа к созданным VM (тип переменной файл)

`WEB_PRODPORT` - порт доступа к приложению после деплоя в kuberclaster (>=30000).

`WEB_TESTPORT` - порт доступа к приложению во время тестирования kuberclaster (>=30000 && != `$WEB_PRODPORT`).

`YC_CLOUD_ID` - CLOUD_ID для доступа к облаку Яндекса

`YC_FOLDER_ID` - CLOUD_ID для доступа к облаку Яндекса

`YC_TOKEN` - токен доступа к CLOUD_ID 

![global_vars](source/images/00-global_vars.png)

Тем не менее, локальные переменные окржения проектов/репозиториев также необходимы для работы pipeline. Для репозитория `infras` это переменные содержащие внутренние и внешние IP адреса VM для успешного развертывания kuber кластера через kubespray (3 внешних и 3 внутренних IP), а репозиторий `applicat` требует только наличия одного IP адреса управления кластером для подключения и развертывания приложения.

Проект/репозиторий infras:
![vars1](source/images/00-vars_infras2.png)

Проект/репозиторий applicat:
![vars2](source/images/00-vars_applicat2.png)

## Этапы выполнения

### Подготовка к созданию облачной инфраструктуры в Ya Cloud. Создание S3 и SA

Код распологается в репозитории https://gitlab.com/dg-netology-diploma/atlantis/-/blob/main/

Перед созданием инфраструктуры требуется выполнить подготовку, а именно установить консольную утилиту `yc` для управления ЯО, а также создать Service Account (уровень доступа storage.editor, в дальнейшем будет использоваться Terraform для работы с инфраструктурой) и S3 Bucket в Яндекс облаке в качестве backend.

Для этого в [gitlab.com/dg-netology-diploma/atlantis/-/blob/main/.gitlab-ci.yml](https://gitlab.com/dg-netology-diploma/atlantis/-/blob/main/.gitlab-ci.yml) используются job: `yc-install` и `trf-preapply` (т.е. stage preinfrabuild), в которых в свою очередь используются вспомогательные bash-скрипты:

- [yc_work.sh](02-yc-export/yc_work.sh) скрипт исключительно для управления облаком ЯО (инициализация, создание SA, создание S3, вывод id и токенов). Единственный входной аргумент определяет действия скрипта. Данный скрипт является вспомогательным и используется в скрипте `start.sh`. 

- [start.sh](start.sh) универсальный скрипт для автоматизации исполнения типовых команд в данном проекте (работа с terraform, вывод переменных, создание backend и workspace для Terraform и т.д.). Единственный входной аргумент определяет действия скрипта. Backend для Terraform в ЯО создается через выполнение скрипта [start.sh sas3-create](start.sh) под созданным ранее сервисным аккаунтом  `tf-sa`.

### Подготовка к созданию облачной инфраструктуры в Ya Cloud. Atlantis

Под Atlantis создан отдельный пользователь в gitlab (@AirAtlantis), добалвен SSH ключ и сгениован токен доступа.
VM с Atlantis поднималась в ручном режиме, все входные данные передаются через переменные окружения. Atlantis поднимается в Docker контейнере. Перечень команд для настройки VM с нуля и конфиг файл atlantis:

Обновление пакетов, установка требуемого ПО для установки Docker, создание rsa ключей:
``` 
sudo apt update
apt install apt-transport-https ca-certificates curl software-properties-common unzip wget
ssh-keygen -t rsa
```

Установка Docker:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo usermod -aG docker ${USER}
su - ${USER}
```

Создания конфиг файла Atlantis и подготовка переменных окружения:
```
mkdir -p ~/atlantis/{.ssh,config}
cp ~/.ssh/id_rsa* ~/atlantis/.ssh/
chmod 600 ~/atlantis/.ssh/
chown 100.1000 -R ~/atlantis/
```

Конфигурационный файл Atlantis server:
```
dgolodnikov@vm-atlantis:~/atlantis/config$ cat server.yaml
repos:
- id: gitlab.com/dg-netology-diploma/atlantis
  branch: /.*/
  allowed_overrides: [apply_requirements, workflow, delete_source_branch_on_merge]
  allow_custom_workflows: true
  delete_source_branch_on_merge: true
```

Экспорт переменных окружения (ключи намеренно изменены), требуется только на стадии запуска контейнера Atlantis Docker.
: 
```
export AWS_ACCESS_KEY_ID=YCAJEK-xdfLLa3453wrwZuhncY
export AWS_SECRET_ACCESS_KEY=YCP_nR5ocz345345WETpwzkyhfnTE_I0iufL
export TF_VAR_YC_TOKEN=AQAAAABd34534wQPU3CEll0YMtIUpeaGu-Kg
export TF_VAR_YC_CLOUD_ID=b1ge34535bv7jejkjhfm9
export TF_VAR_YC_FOLDER_ID=b1ge345348tepos1sa

export ATLANTISURL=http://`curl 2ip.ru`:4141
export GLUSERNAME=AirAtlantis
export GLTOKEN=glpat-KHvmxzNj36356hpHwDZRi
export GLSECRET=57ba18321c80ff12356356356356356d5c930a5f31397ca69f463525af4aa1920
export REPO_ALLOWLIST=gitlab.com/dg-netology-diploma/atlantis
```

Запуск Atlantis в контйенере:
```
dgolodnikov@vm-atlantis:~/atlantis/config$ docker run -d -p 4141:4141 \
--env GIT_SSH_COMMAND="ssh -i /home/atlantis/.ssh/id_rsa.pub -o 'StrictHostKeyChecking no'" \
-v /home/dgolodnikov/atlantis:/home/atlantis \
--env AWS_ACCESS_KEY_ID \
--env AWS_SECRET_ACCESS_KEY \
--env TF_VAR_YC_TOKEN \
--env TF_VAR_YC_CLOUD_ID \
--env TF_VAR_YC_FOLDER_ID \
--name atlantis \
--restart=always \
ghcr.io/runatlantis/atlantis server \
--atlantis-url="$ATLANTISURL" \
--gitlab-user="$GLUSERNAME" \
--gitlab-token="$GLTOKEN" \
--gitlab-webhook-secret="$GLSECRET" \
--repo-allowlist="$REPO_ALLOWLIST" \
--repo-config=/home/atlantis/config/server.yaml

dgolodnikov@vm-atlantis:~/atlantis/config$ docker ps
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS         PORTS                                       NAMES
c7b740733b9a   ghcr.io/runatlantis/atlantis   "docker-entrypoint.s…"   3 seconds ago   Up 2 seconds   0.0.0.0:4141->4141/tcp, :::4141->4141/tcp   atlantis
```

Проверка UI Atlantis:
![Atlantis](source/images/03-ui_atlantis.png)

Даллее необходимо настроить WebHook в репозитории Gitlab согласно документации https://www.runatlantis.io/docs/configuring-webhooks.html#gitlab:

![webhook](source/images/03-webhook.png) 

И добавить файл конфигурации (опционально) в корень репозитория. В нашем случае это необходимо, так как 
- *.tf файлы лежат не в корне
- используется workspace stage (не дефолт)

Файл конфигурации atlantis  на стороне репозиттория [atlantis.yaml](https://gitlab.com/dg-netology-diploma/atlantis/-/blob/main/atlantis.yaml).

### Cоздание облачной инфраструктуры в Ya Cloud

Код распологается в репозитории https://gitlab.com/dg-netology-diploma/atlantis/-/blob/main/

Развертывания облачной инфраструктуры в ЯО при помощи Terraform можно выполнить двумя способами:

1) С помощью Atlantis, создав MergeRequest и написав 'atlantis apply` в поле комментариев (согласно ТЗ).

Создание MR:
![Atlantis_MR](source/images/03-createMR.png)

"Диалог" с Atlantis в поле комментариев при создании инфраструктуры:
![Atlantis_apply1](source/images/03-atlantis_mr1.png)
![Atlantis_apply2](source/images/03-atlantis_mr2.png)

2) С помощью gitlab-сi [gitlab.com/dg-netology-diploma/atlantis/-/blob/main/.gitlab-ci.yml](https://gitlab.com/dg-netology-diploma/atlantis/-/blob/main/.gitlab-ci.yml) запустив вручную job: `trf-apply`. Данный метод был создан дополнительно для освоения навыков работы в CICD gitlab.

Настройка workspaces для Terraform (используется один workspace `stage`) выполняется в [start.sh infra-create](start.sh). Имя workspace задается в переменной `TF_WORKSPACE` внутри скрипта.
 
*<b>Ожидаемый результат:</b>*

*1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий*

Создание инфраструктуры выполняется внутри pipeline gitlab, либо с помощью Atlantis (см. криншоты выше)

![infra_build](source/images/01-infra_build.png)
![infra_build2](source/images/01-infra_build_screen2.png)

*2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.*

Выполняется через корректировку манифестов terraform [15-terraform](15-terraform/), созданием MergeRequest в main и применение конфигурации через Atlantis apply. 

---
### Создание Kubernetes кластера

Код распологается в репозитории https://gitlab.com/dg-netology-diploma/infras

*На этом этапе необходимо создать кластер на базе предварительно созданной инфраструктуры. Требуется обеспечить доступ к ресурсам из Интернета.*

Для этого в [gitlab-ci.yml](.gitlab-ci.yml) используются jobs: `kuber-install` в котором используется kubespray c подготовленным inventory и конфигурацией кластера: <br>
[20-kube/inventory/kuber/hosts.yaml](20-kube/inventory/kuber/hosts.yaml)<br>
[20-kube/inventory/kuber/group_vars/k8s_cluster/k8s-cluster.yml](20-kube/inventory/kuber/group_vars/k8s_cluster/k8s-cluster.yml)

Также для обеспечения доступа к kuber кластеру используется подготовленный ansible-playbook и inventory:

[22-kubeaccess/site.yaml](22-kubeaccess/site.yaml)<br>
[22-kubeaccess/inventory/hosts.yaml](22-kubeaccess/inventory/hosts.yaml)

*<b>Ожидаемый результат:</b>*

*1. Работоспособный Kubernetes кластер.*

![kuber_install](source/images/01-kuber_install.png)

Из логов pipeline:
```
PLAY RECAP *********************************************************************
cp1                        : ok=730  changed=147  unreachable=0    failed=0    skipped=1254 rescued=0    ignored=8   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node1                      : ok=506  changed=93   unreachable=0    failed=0    skipped=776  rescued=0    ignored=1   
node2                      : ok=506  changed=93   unreachable=0    failed=0    skipped=775  rescued=0    ignored=1 

$ kubectl get nodes
NAME    STATUS   ROLES           AGE     VERSION
cp1     Ready    control-plane   7m42s   v1.24.10
node1   Ready    <none>          5m50s   v1.24.10
node2   Ready    <none>          5m50s   v1.24.10
```

*2. В файле `~/.kube/config` находятся данные для доступа к кластеру*

В pipeline gitlab для обеспечения доступа к созданному kuber кластеру из VM runner ипользуется плейбук [22-kubeaccess](22-kubeaccess/)<br>.   Вывод выполнен со вспомогательной машины после выполнения плейбука.
```
dgolodnikov@pve-vm1:~/REPO/infras/22-kubeaccess$ cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0t
    ...
    S0tCg==
    server: https://158.160.52.228:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJ
    ...
    tCg==
    client-key-data: LS0tLS1C
    ...
    tLS0tLQo=

```

*3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.*

```
dgolodnikov@pve-vm1:~/REPO/infras/22-kubeaccess$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-7f679c5d6f-glscz   1/1     Running   0          32m
kube-system   calico-node-84pxn                          1/1     Running   0          33m
kube-system   calico-node-n94sb                          1/1     Running   0          33m
kube-system   calico-node-sxnd5                          1/1     Running   0          33m
kube-system   coredns-5867d9544c-crnwv                   1/1     Running   0          31m
kube-system   coredns-5867d9544c-h97cm                   1/1     Running   0          30m
kube-system   dns-autoscaler-59b8867c86-stb55            1/1     Running   0          30m
kube-system   kube-apiserver-cp1                         1/1     Running   1          36m
kube-system   kube-controller-manager-cp1                1/1     Running   1          36m
kube-system   kube-proxy-b989j                           1/1     Running   0          34m
kube-system   kube-proxy-f4bt4                           1/1     Running   0          34m
kube-system   kube-proxy-jbpl6                           1/1     Running   0          34m
kube-system   kube-scheduler-cp1                         1/1     Running   1          36m
kube-system   nginx-proxy-node1                          1/1     Running   0          33m
kube-system   nginx-proxy-node2                          1/1     Running   0          33m
kube-system   nodelocaldns-b6xdb                         1/1     Running   0          30m
kube-system   nodelocaldns-t6skj                         1/1     Running   0          30m
kube-system   nodelocaldns-wmw4q                         1/1     Running   0          30m
monitoring    alertmanager-main-0                        2/2     Running   0          27m
monitoring    alertmanager-main-1                        2/2     Running   0          27m
monitoring    alertmanager-main-2                        2/2     Running   0          27m
monitoring    blackbox-exporter-6fb744d4fc-6ltxg         3/3     Running   0          27m
monitoring    grafana-6b5756895c-bmw9m                   1/1     Running   0          27m
monitoring    kube-state-metrics-687f54fbc-mgz5r         3/3     Running   0          27m
monitoring    node-exporter-4swlp                        2/2     Running   0          27m
monitoring    node-exporter-6ch97                        2/2     Running   0          27m
monitoring    node-exporter-bqnxd                        2/2     Running   0          27m
monitoring    prometheus-adapter-56b86cdfc5-c2gwj        1/1     Running   0          27m
monitoring    prometheus-adapter-56b86cdfc5-cdtgn        1/1     Running   0          27m
monitoring    prometheus-k8s-0                           2/2     Running   0          27m
monitoring    prometheus-k8s-1                           2/2     Running   0          27m
monitoring    prometheus-operator-956fc6b8f-6869l        2/2     Running   0          27m
```
---
### Создание тестового приложения

Код (деплой мониторинг) распологается в репозитории https://gitlab.com/dg-netology-diploma/infras
Код (билд, тест и деплой приложения) распологается в репозитории https://gitlab.com/dg-netology-diploma/Applicat

Подготовка тестового приложения заключается в сборке контейнера с nginx с тестовой страницей `index.html` и выгрузке его в докерхаб.
Репозиторий тестового приложения `applicat` распологается здесь https://gitlab.com/dg-netology-diploma/Applicat.

Сборка осуществляется автоматически в разделе CICD в [gitlab-ci.yml](https://gitlab.com/dg-netology-diploma/Applicat/-/blob/main/.gitlab-ci.yml) используя jobs: app-build.  Сборка контейнера выполняется с использованием kaniko. Для сборки контейнера подготовлены:
- Dockerfile https://gitlab.com/dg-netology-diploma/Applicat/-/blob/main/10-docker/Dockerfile
- Простейший index.html https://gitlab.com/dg-netology-diploma/Applicat/-/blob/main/10-docker/index.html (далее в CICD он будет видоизменятся)

Выгрузка выполняется в реестр docker hub автоматически в разделе CICD по адресу:
- https://hub.docker.com/repository/docker/dgolodnikov/applicat/general


*<b>Ожидаемый результат:</b>*

*1. Git репозиторий с тестовым приложением и Dockerfile*

https://gitlab.com/dg-netology-diploma/Applicat

*2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform*

https://hub.docker.com/repository/docker/dgolodnikov/applicat/general

---
### Подготовка cистемы мониторинга и деплой приложения

https://gitlab.com/dg-netology-diploma/Applicat


  Система мониторинга будет разворачиваться на базе пакета из репозитория [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus). Он уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter).

  Для развертывания системы монторинга в [gitlab-ci.yml](.gitlab-ci.yml) используются jobs: `monitor-install` в котором реализуется  установка пакета в доступный kuber кластер согласно документации. Для реализации доступа к grafana был создан kube манифест с целью создания сервиса с type NodePort: 25-monitoring/grafana-access.yaml, а также удалена сетевая политика после установки.

  Для развертывания и апгрейда приложения было решено использовать helm, как макисмально удобный и популярный инструмент для шаблонизации установки. В нашем случае шаблонизация была необходима для установки порт доступа к приложению, версия образа приложения, а также возможность upgrade приложения. 

  Для этого был подготовлен helm chart https://gitlab.com/dg-netology-diploma/Applicat/-/tree/main/30-helm/webapp.
  Установка приложения выполняется в [gitlab-ci.yml](https://gitlab.com/dg-netology-diploma/Applicat/-/blob/main/.gitlab-ci.yml) используется jobs: app-test (в namespace test) и app-deploy (в namespace prod).
  
*<b>Ожидаемый результат:</b>*

*1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.*

Конфигурация kubspray [20-kube/](20-kube/)<br>
Доп.конфигурация системы мониторинга [25-monitoring/](25-monitoring/)
Helm chart для установки приложения https://gitlab.com/dg-netology-diploma/Applicat/-/tree/main/30-helm/webapp

*2. Http доступ к web интерфейсу grafana.*

  URL доступа к Grafana выводится внутри pipeline jobs monitor-install (http://158.160.35.250:30080/):

![monitor_install](source/images/01-monitor_install_screen.png)

*3. Дашборды в grafana отображающие состояние Kubernetes кластера.*

Дашборд ниже на скриншоте:

![monitor_install](source/images/01-monitor_ui.png)

*4. Http доступ к тестовому приложению.*

URL доступа к приложению выводится в pipeline:

```
$ helm upgrade --install --create-namespace -n prod --set image.tag=$CI_COMMIT_TAG --set ipaccess=$vm_ip1 --set spec.ports.nodePort=${WEB_PRODPORT} $CI_PROJECT_TITLE 30-helm/webapp
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
Release "applicat" does not exist. Installing it now.
NAME: applicat
LAST DEPLOYED: Fri May 26 02:35:11 2023
NAMESPACE: prod
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
---------------------------------------------------------
Deployed version/tag 1.0.3. Release name: applicat
---------------------------------------------------------
"Visit http://158.160.35.250:30080 to use your application"
Cleaning up project directory and file based variables
00:01
Job succeeded
```
Т.е. тестовое прложение http://158.160.35.250:30080/

![app_deploy](source/images/02-app_web.png)

---
### Установка и настройка CI/CD

Настройка CICD выполнялась в Gitlab CICD, все инструкции выполнялись либо в заранее подготовленных образах, либо в уже готовых (kaniko, terraform).

CICD развертывания облачной инфраструктуры: [gitlab-ci.yml](https://gitlab.com/dg-netology-diploma/atlantis/-/blob/main/.gitlab-ci.yml)
CICD развертывания инфраструктуры (kuber кластер + мониторинг): [gitlab-ci.yml](gitlab-ci.yml)
CICD развертывания приложения: [gitlab-ci.yml](https://gitlab.com/dg-netology-diploma/Applicat/-/blob/main/.gitlab-ci.yml)

Для работы CICD требуется входные переменные, указанные в разделе [Введение](#введение).
Некоторые Jobs в pipeline выполнены как manual для удобства, например для удаления системы мониторинга и развертывания облачной инфраструктуры.
При создании тега на коммит в репозитории с приложением (applicat) кроме деплоя приложения, выполняется также и тестирование в gitlab stage `test`. 

*<b>Ожидаемый результат:</b>*

*1. Интерфейс ci/cd сервиса доступен по http.*

CICD развертывания инфраструктуры: https://gitlab.com/dg-netology-diploma/infras/-/pipelines
CICD развертывания приложения: https://gitlab.com/dg-netology-diploma/Applicat/-/pipelines

*2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.*

В качестве тега образа используется короткий хеш комита.

![app-build](source/images/02-app-build.png) <br>

![Papp-build-push](source/images/02-app-build-push.png)


*3. При создании тега (например, v1.0.3) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.*

В качестве тега образа используется тег (например 1.0.3)

![app-build-deploy](source/images/02-app-build-deploy.png)<br>
![app-build-push](source/images/02-app-build-push.png)
---
## Что необходимо для сдачи задания?

*1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.*

Terraform манифесты [15-terraform/](15-terraform/)

*2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.*

Пример MR c Atlantis: https://gitlab.com/dg-netology-diploma/atlantis/-/merge_requests/6

![Atlantis_apply1](source/images/03-atlantis_mr1.png)
![Atlantis_apply2](source/images/03-atlantis_mr2.png)

*3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.*

Конфигурация kubspray [20-kube/](20-kube/)<br>

*4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.*

Dockerfile https://gitlab.com/dg-netology-diploma/Applicat/-/tree/main/10-docker <br>
Ссылка на докерхаб https://hub.docker.com/repository/docker/dgolodnikov/applicat/general <br>
или `docker push dgolodnikov/applicat:1.0.3`

*5. Репозиторий с конфигурацией Kubernetes кластера.*

Конфигурация kubspray [20-kube/](20-kube/)<br>
Доп.конфигурация системы мониторинга [25-monitoring/](25-monitoring/)<br>
Helm chart для установки приложения https://gitlab.com/dg-netology-diploma/Applicat/-/tree/main/30-helm/webapp

*6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.*

URL Application http://158.160.35.250:30080/ <br>
URL Grafana http://158.160.35.250:30123/

*7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)*

Используется https://gitlab.com/ 

---
## Вопросы:

1) В CICD думаю логично было бы деплоить приложение в кластер не только по наличию тега в коммите, но и по коммиту только в ветку main.
Но вот такая конструкция в CICD gitlab у меня не заработала: 
```
app-deploy:
  stage: deploy
  rules:
    - if: '$CI_COMMIT_BRANCH == "main" && $CI_COMMIT_TAG != "null"' 
```
Эксперименты ни к чему не привели =)

### Ответ:
```
 - if: '$CI_COMMIT_BRANCH == "main" && $CI_COMMIT_TAG' 
```

2) Проблема передачи артефактов между pipeline разных репозиториев. Т.е. в текущей работе у меня три CICD процесса в каждом из репозиториев. Соответсвенно результаты из одного, необходимо передавать в другой как входные данные. Т.е. например при развертывании приложения нужно знать IP адрес мастер ноды кубер кластера, который был определен на предиущих этапах в другом pipeline. 
На данном этапе его приходиться забивать руками в Settings CICD Variables проекта, что в прицнипе наверное приемлемо, но неудобно. 
Как-то это можно решить? Какой bestpractise vault? Pipeline cache?

### Ответ:
“родительский” пайплайн, который будет с параметрами запускать “дочерние”: https://docs.gitlab.com/ee/ci/pipelines/downstream_pipelines.html 
Если же проблема только в адресах машин для ansible, то можно использовать динамические inventory.
