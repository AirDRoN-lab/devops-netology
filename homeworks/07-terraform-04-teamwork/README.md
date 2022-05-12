# Домашнее задание к занятию "7.4. Средства командной работы над инфраструктурой."

## Задача 1. Настроить terraform cloud (необязательно, но крайне желательно).

В это задании предлагается познакомиться со средством командой работы над инфраструктурой предоставляемым
разработчиками терраформа. 

1. Зарегистрируйтесь на [https://app.terraform.io/](https://app.terraform.io/).
(регистрация бесплатная и не требует использования платежных инструментов).
2. Создайте в своем github аккаунте (или другом хранилище репозиториев) отдельный репозиторий с
 конфигурационными файлами прошлых занятий (или воспользуйтесь любым простым конфигом).
3. Зарегистрируйте этот репозиторий в [https://app.terraform.io/](https://app.terraform.io/).
4. Выполните plan и apply. 

В качестве результата задания приложите снимок экрана с успешным применением конфигурации.

### Ответ
Снимок успешного применения apply и plan по [ссылке](https://github.com/AirDRoN-lab/devops-netology/blob/main/homeworks/07-terraform-04-teamwork/Screen_TerraCloud_Success.JPG).

## Задача 2. Написать серверный конфиг для атлантиса. 

Смысл задания – познакомиться с документацией 
о [серверной](https://www.runatlantis.io/docs/server-side-repo-config.html) конфигурации и конфигурации уровня 
 [репозитория](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html).

Создай `server.yaml` который скажет атлантису:
1. Укажите, что атлантис должен работать только для репозиториев в вашем github (или любом другом) аккаунте.
2. На стороне клиентского конфига разрешите изменять `workflow`, то есть для каждого репозитория можно 
будет указать свои дополнительные команды. 
3. В `workflow` используемом по-умолчанию сделайте так, что бы во время планирования не происходил `lock` состояния.

Создай `atlantis.yaml` который, если поместить в корень terraform проекта, скажет атлантису:
1. Надо запускать планирование и аплай для двух воркспейсов `stage` и `prod`.
2. Необходимо включить автопланирование при изменении любых файлов `*.tf`.

В качестве результата приложите ссылку на файлы `server.yaml` и `atlantis.yaml`.
### Ответ

Установка атлантис и ngrok по [доке](https://www.runatlantis.io/guide/testing-locally.html#download-atlantis):
```
vagrant@server1:~$ curl https://github.com/runatlantis/atlantis/releases/download/v0.19.2/atlantis_linux_amd64.zip -o "atlantis_linux.zip"
vagrant@server1:~$ unzip atlantis_linux.zip -d /usr/local/bin

vagrant@server1:~$ atlantis version
atlantis 0.19.2

vagrant@server1:~$ curl https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
vagrant@server1:~$ sudo tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin

vagrant@server1:~$ ngrok version
ngrok version 3.0.3
```

Запуск ngrok ```vagrant@server1:~$ ngrok http 4141``` и его [вывод](https://github.com/AirDRoN-lab/devops-netology/blob/main/homeworks/07-terraform-04-teamwork/Screen_Atlantis_3_ngrok.JPG)

Экспортируем переменные:
```
export URL="https://https://4923-77-91-103-153.eu.ngrok.io"
export USERNAME="AirDRoN-lab"
export REPO_ALLOWLIST="github.com/AirDRoN-lab/devops-netology"
export SECRET="32684905744417222656"
export TOKEN="ghp_X4AbhIEgcsp0cWXjk5f0MfwvEJsFRu4TKCj2"
```

Выполняем настройку WebHook в GitHub согласно [документации](https://www.runatlantis.io/guide/testing-locally.html#download-atlantis) и запускаем atlantis
```
atlantis server --atlantis-url="$URL" --gh-user="$USERNAME" --gh-token="$TOKEN" --gh-webhook-secret="$SECRET" --repo-allowlist="$REPO_ALLOWLIST" --repo-config=atlantis_server_cfg.yaml
```

Файлы конфигурации использовались следющие (правки согласно ТЗ):
на стороне сервера [atlantis_server_cfg.yaml](https://github.com/AirDRoN-lab/devops-netology/blob/main/homeworks/07-terraform-04-teamwork/atlantis_server_cfg.yaml)
на стороне репозитория [atlantis.yaml](https://github.com/AirDRoN-lab/devops-netology/blob/main/homeworks/07-terraform-04-teamwork/atlantis.yaml)

Скриншоты успешного выполнения plan и apply из диалога PR:
[cкрин_1](https://github.com/AirDRoN-lab/devops-netology/blob/main/homeworks/07-terraform-04-teamwork/Screen_Atlantis_1.JPG), 
[cкрин_2](https://github.com/AirDRoN-lab/devops-netology/blob/main/homeworks/07-terraform-04-teamwork/Screen_Atlantis_2.JPG)

## Задача 3. Знакомство с каталогом модулей. 

1. В [каталоге модулей](https://registry.terraform.io/browse/modules) найдите официальный модуль от aws для создания
`ec2` инстансов. 
2. Изучите как устроен модуль. Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно 
ресурс `aws_instance` без помощи модуля?
3. В рамках предпоследнего задания был создан ec2 при помощи ресурса `aws_instance`. 
Создайте аналогичный инстанс при помощи найденного модуля.   

В качестве результата задания приложите ссылку на созданный блок конфигураций. 
### Ответ
