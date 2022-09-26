# Домашнее задание к занятию "09.04 Jenkins"

## Подготовка к выполнению

1. Создать 2 VM: для jenkins-master и jenkins-agent.
2. Установить jenkins при помощи playbook'a.
3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.

## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.
4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`.
8. Отправить ссылку на репозиторий с ролью и Declarative Pipeline и Scripted Pipeline.

### Ответ

Freestyle Job сделана, [скриншот выполнения](FJ_success.PLG)
Declarative Pipeline Job сделана, [скриншот выполнения](PL_success.JPG). Скрипт перенесен в репозиторий [здесь](pipeline/Jenkinsfile) и [здесь](https://github.com/AirDRoN-lab/ansible-vector-role/blob/main/Jenkinsfile).
Multibranch Pipeline Pipeline Job сдалана, [скриншот выполнения](FJ_success.JPG).
Scripted Pipeline создан, настроен параметр prod_run (тип boolen). Скрипт выложен в репозитории [здесь](./pipeline/ScriptedJenkinsfile). Скриншот выполнения pipeline [здесь](SCpipeline__success.JPG).

Во время отладки на ноде Jenkins были выполнены команды:

```bash
sudo usermod -a -G sudo jenkins
sudo visudo 
# добавлена строка jenkins ALL=(ALL) NOPASSWD: ALL
```

Итоговый [скриншот](All_pipeline.JPG) выполненных pipeline. 
Репозиторий с использованной ролью https://github.com/AirDRoN-lab/ansible-vector-role

## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решением с названием `AllJobFailure.groovy`.
2. Создать Scripted Pipeline таким образом, чтобы он мог сначала запустить через Ya.Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Тем самым, мы должны по нажатию кнопки получить готовую к использованию систему.

### Ответ

Будет выполнена позже (после сдачи хвостов)

