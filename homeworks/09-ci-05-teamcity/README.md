# Домашнее задание к занятию "09.05 Teamcity"

## Подготовка к выполнению

1. В Ya.Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`
2. Дождитесь запуска teamcity, выполните первоначальную настройку
3. Создайте ещё один инстанс(2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`
4. Авторизуйте агент
5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity)
6. Создать VM (2CPU4RAM) и запустить [playbook](./infrastructure)

### Ответ:

Подготовлена ифраструктура в яндексе, [создано 3ВМ](YC_VMs.JPG).<br>
Сделан [форк](https://github.com/AirDRoN-lab/example-teamcity).
Доступ к TeamCity по порту 8111, к Nexus 8081.

## Основная часть

1. Создайте новый проект в teamcity на основе fork
2. Сделайте autodetect конфигурации
3. Сохраните необходимые шаги, запустите первую сборку master'a
4. Поменяйте условия сборки: если сборка по ветке `master`, то должен происходит `mvn clean deploy`, иначе `mvn clean test`
5. Для deploy будет необходимо загрузить [settings.xml](./teamcity/settings.xml) в набор конфигураций maven у teamcity, предварительно записав туда креды для подключения к nexus
6. В pom.xml необходимо поменять ссылки на репозиторий и nexus
7. Запустите сборку по master, убедитесь что всё прошло успешно, артефакт появился в nexus
8. Мигрируйте `build configuration` в репозиторий
9. Создайте отдельную ветку `feature/add_reply` в репозитории
10. Напишите новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`
11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике
12. Сделайте push всех изменений в новую ветку в репозиторий
13. Убедитесь что сборка самостоятельно запустилась, тесты прошли успешно
14. Внесите изменения из произвольной ветки `feature/add_reply` в `master` через `Merge`
15. Убедитесь, что нет собранного артефакта в сборке по ветке `master`
16. Настройте конфигурацию так, чтобы она собирала `.jar` в артефакты сборки
17. Проведите повторную сборку мастера, убедитесь, что сбора прошла успешно и артефакты собраны
18. Проверьте, что конфигурация в репозитории содержит все настройки конфигурации из teamcity
19. В ответ предоставьте ссылку на репозиторий

### Ответ:
Загружен SSH ключ (публичный) для работы с репозиторием. Выполнена настройка Versioned Settings проекта Netology для выгрузки конфигурации. [Скриншот настроек](Vers_config.JPG)  
Для решения п.4 было создано два билдстепа с разными условиями: `teamcity.build.branch does not equal master` и `teamcity.build.branch equals master`. В итоге выполняется, либо первый с `mvn clean deploy`, либо второй с `mvn clean deploy`. Файл конфигурации maven [settings.xml](settings.xml) в котором был изменены только nexus id.
Файл конфигурации проекта maven [pom.xml](pom.xml), в котором изменен Nexus ip и id (изначально было `<version>0.0.3</version>`). <br>
При первом запуске сборки (по master) все прошло успешно, артефакт выложен в Nexus, версия 0.0.2. [Скриншот](Nexus_Artifacts.JPG).
Согласно заданию, была создана доп ветка `feature/add_reply` в репозитории https://github.com/AirDRoN-lab/example-teamcity. Дописан метод для класса Welcomer и тест для него (см. ниже):

```java
public String sayHunter(){
		return "Mmm, hunter Engineering is a global leader in wheel alignment machines, wheel balancers, tire changers, brake service equipment";
	}
```

```java
@Test
	public void welcomerSaysHunterCheck(){
		assertThat(welcomer.sayHunter(), containsString("hunter"));
	}
```

Изменения выложены в репозиторий, сборка завпустилась автоматически по ветке `feature/add_reply`, пройдены тесты. Но в nexus артефакт не попал, т.к. необходимо изменить `<version>` в [pom.xml](pom.xml).
После изменения pom.xml `<version>0.0.3</version>` [артефакт](Nexus_Artifacts.JPG) в Nexus появился (версия 0.0.3).

Итория всех проведенных сборок в TC на [скриншоте](TC_history.JPG). <br>
Cсылка на репозиторий https://github.com/AirDRoN-lab/example-teamcity <br>
[файл1](tc_config1_formaster.cfg) и [файл2](tc_config2_forfeature.cfg) конфигурации Teamcity. Но конфигурация по факту одна, так как условие билдстепа было написано в начале. <br>