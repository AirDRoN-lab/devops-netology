# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/) либо [gitlab ci](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---

## Ответ


### Развертывание kubernettes 

Перенос private ключей на VM для кубера: 
```
dgolodnikov@pve-vm1:~$ cat ~/.ssh/id_rsa.pub | ssh dgolodnikov@$vm_ip1 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

dgolodnikov@pve-vm1:~$ cat ~/.ssh/id_rsa.pub | ssh dgolodnikov@$vm_ip2 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

dgolodnikov@pve-vm1:~$ cat ~/.ssh/id_rsa.pub | ssh dgolodnikov@$vm_ip3 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Отключаем sudo для пользователя под котором будет выполняться установка:
```
ssh dgolodnikov@$vm_ip1 "echo 'dgolodnikov ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/dgolodnikov"

ssh dgolodnikov@$vm_ip2 "echo 'dgolodnikov ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/dgolodnikov"

ssh dgolodnikov@$vm_ip3 "echo 'dgolodnikov ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/dgolodnikov"
```

Запускаем установку (приедварительно необходимо сконфигурировать крипт start.sh на предмет IP адресации нод):
```
./start.sh play
```
Обеспечивает доступ к кластеру на мастер ноде и компьютере администратора:
```
dgolodnikov@pve-vm1:~$ ssh dgolodnikov@$vm_ip1 "mkdir -p ~/.kube && sudo cp /etc/kubernetes/admin.conf ~/.kube/config && sudo chown dgolodnikov:dgolodnikov ~/.kube/config"

dgolodnikov@pve-vm1:~$ scp dgolodnikov@$vm_ip1:~/.kube/config ~/.kube/config
```

Проверяем c VM администратора:
```
dgolodnikov@pve-vm1:~$ kubectl get node
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   13h   v1.25.6
node1   Ready    <none>          13h   v1.25.6
node2   Ready    <none>          13h   v1.25.6

dgolodnikov@pve-vm1:~/.kube$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-75748cc9fd-zzjx7   1/1     Running   0          13h
kube-system   calico-node-pb942                          1/1     Running   0          13h
kube-system   calico-node-plzqx                          1/1     Running   0          13h
kube-system   calico-node-zrt2p                          1/1     Running   0          13h
kube-system   coredns-588bb58b94-6fdpv                   1/1     Running   0          13h
kube-system   coredns-588bb58b94-6vzkx                   1/1     Running   0          13h
kube-system   dns-autoscaler-5b9959d7fc-qfxrc            1/1     Running   0          13h
kube-system   kube-apiserver-cp1                         1/1     Running   0          13h
kube-system   kube-controller-manager-cp1                1/1     Running   1          13h
kube-system   kube-proxy-4jvdz                           1/1     Running   0          29m
kube-system   kube-proxy-lj5vz                           1/1     Running   0          29m
kube-system   kube-proxy-txskv                           1/1     Running   0          29m
kube-system   kube-scheduler-cp1                         1/1     Running   1          13h
kube-system   nginx-proxy-node1                          1/1     Running   0          13h
kube-system   nginx-proxy-node2                          1/1     Running   0          13h
kube-system   nodelocaldns-4wkmx                         1/1     Running   0          13h
kube-system   nodelocaldns-64lbz                         1/1     Running   0          13h
kube-system   nodelocaldns-x4bpx                         1/1     Running   0          13h
```

### Развертывание Helm
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
```
dgolodnikov@pve-vm1:~/REPO/devops-netology/homeworks/00-diploma$ helm version
version.BuildInfo{Version:"v3.10.3", GitCommit:"835b7334cfe2e5e27870ab3ed4135f136eecc704", GitTreeState:"clean", GoVersion:"go1.18.9"}
```

```
git clone https://github.com/prometheus-operator/kube-prometheus.git
kubectl apply --server-side -f manifests/setup
kubectl apply -f manifests/
```

```
kubectl delete -n monitoring networkpolices grafana
```
Доступ к Grafana осуществляется по порту 30123, т.к.:
```
dgolodnikov@pve-vm1:~$ kubectl get -n monitoring svc
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
alertmanager-main       ClusterIP   10.233.62.189   <none>        9093/TCP,8080/TCP            73d
alertmanager-operated   ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   73d
blackbox-exporter       ClusterIP   10.233.52.244   <none>        9115/TCP,19115/TCP           73d
grafana                 ClusterIP   10.233.5.62     <none>        3000/TCP                     73d
grafana-access          NodePort    10.233.16.8     <none>        3000:30123/TCP               73d
kube-state-metrics      ClusterIP   None            <none>        8443/TCP,9443/TCP            73d
node-exporter           ClusterIP   None            <none>        9100/TCP                     73d
prometheus-adapter      ClusterIP   10.233.21.223   <none>        443/TCP                      73d
prometheus-k8s          ClusterIP   10.233.23.139   <none>        9090/TCP,8080/TCP            73d
prometheus-operated     ClusterIP   None            <none>        9090/TCP                     73d
prometheus-operator     ClusterIP   None            <none>        8443/TCP                     73d
```
