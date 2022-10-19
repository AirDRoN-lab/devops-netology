# Домашнее задание к занятию "10.03. Grafana"

## Задание повышенной сложности

**В части задания 1** не используйте директорию [help](./help) для сборки проекта, самостоятельно разверните grafana, где в 
роли источника данных будет выступать prometheus, а сборщиком данных node-exporter:
- grafana
- prometheus-server
- prometheus node-exporter

За дополнительными материалами, вы можете обратиться в официальную документацию grafana и prometheus.

В решении к домашнему заданию приведите также все конфигурации/скрипты/манифесты, которые вы 
использовали в процессе решения задания.

**В части задания 3** вы должны самостоятельно завести удобный для вас канал нотификации, например Telegram или Email
и отправить туда тестовые события.

В решении приведите скриншоты тестовых событий из каналов нотификаций.

## Обязательные задания

### Задание 1
Используя директорию [help](./help) внутри данного домашнего задания - запустите связку prometheus-grafana.

Зайдите в веб-интерфейс графана, используя авторизационные данные, указанные в манифесте docker-compose.

Подключите поднятый вами prometheus как источник данных.

Решение домашнего задания - скриншот веб-интерфейса grafana со списком подключенных Datasource.

## Задание 2
Изучите самостоятельно ресурсы:
- [promql-for-humans](https://timber.io/blog/promql-for-humans/#cpu-usage-by-instance)
- [understanding prometheus cpu metrics](https://www.robustperception.io/understanding-machine-cpu-usage)

Создайте Dashboard и в ней создайте следующие Panels:
- Утилизация CPU для nodeexporter (в процентах, 100-idle)
- CPULA 1/5/15
- Количество свободной оперативной памяти
- Количество места на файловой системе

Для решения данного ДЗ приведите promql запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.

## Задание 3
Создайте для каждой Dashboard подходящее правило alert (можно обратиться к первой лекции в блоке "Мониторинг").

Для решения ДЗ - приведите скриншот вашей итоговой Dashboard.

## Задание 4
Сохраните ваш Dashboard.

Для этого перейдите в настройки Dashboard, выберите в боковом меню "JSON MODEL".

Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.

В решении задания - приведите листинг этого файла.

## Ответ единый по всем заданиям

Скачаны следующийеобразы контейнеров:
```
ubuntu@netbox:~$ docker image ls
REPOSITORY                          TAG               IMAGE ID       CREATED         SIZE
grafana/grafana                     9.2.0-ubuntu      303c8411bfea   5 days ago      415MB
prom/prometheus                     latest            6b9895947e9e   9 days ago      220MB
prom/node-exporter                  v1.4.0            d3e443c987ef   2 weeks ago     22.3MB
prometheuscommunity/bind-exporter   v0.5.0            28662c554f67   10 months ago   21.8MB
```

Запуск grafana и prometheus: 
```
docker run -d --name=prometheus  -p 9090:9090  -v /opt/prometheus/:/etc/prometheus/ prom/prometheus
docker run -d --name=grafana  -p 3000:3000 grafana/grafana:9.2.0-ubuntu
```
Запуск node-exporter: 
```
ubuntu@netbox:~$ cat /opt/node_exporter/docker-compose.yml
 nodeexporter:
    image: prom/node-exporter:v1.4.0
    container_name: nodeexporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
    ports:
      - 9100:9100
ubuntu@netbox:/opt/node_exporter$ docker-compose up -d
```
Запуск bind-exporter (факультативный запуск): 
```
docker run --name=bindexporter --network host -p 9101:9100 -d prometheuscommunity/bind-exporter:v0.5.0 --bind.stats-url http://10.129.144.183:8953
```

Добавлены таргеты в Prometheus, [Prometheus_target.JPG](Prometheus_target.JPG).

В Grafana добавляем источник данных Prometheus `http://10.129.144.183:9090`, [Grafana_sources.JPG](Grafana_sources.JPG).

Создаем дашборд и добавляенм в него следующие promql запросы  согласно ДЗ:

- Утилизация CPU для nodeexporter (в процентах, 100-idle)
```
100 - (avg(irate(node_cpu_seconds_total{job="prometheus", mode="idle", instance="10.129.144.183:9100"}[5m])) * 100)
```

- CPULA 1/5/15
```
node_load1
node_load5
node_load15
```
- Количество свободной оперативной памяти (в том числе отдельно на bind_exporter и node_exporter)
```
process_virtual_memory_bytes{instance="10.129.144.183:9100"}
process_virtual_memory_bytes{instance="10.129.144.183:9119"}
node_memory_MemAvailable_bytes
node_memory_MemTotal_bytes
node_memory_MemFree_bytes
```
- Количество места на файловой системе, 

```
node_filesystem_avail_bytes{instance="10.129.144.183:9100", mountpoint="/"}
node_filesystem_avail_bytes{instance="10.129.144.183:9100", mountpoint="/mnt"}
```

Итоговый дашборд вышел следующим, см. рис [Grafana_dashboard.JPG](Grafana_dashboard.JPG).

После заведения алертов для каждого из дашбордов в названиях панелей появился значок статуса, см. рис [Grafana_dashboard2.JPG](Grafana_dashboard2.JPG).

Файл настроек дашборда приведен в репозитории,  [Grafana_dashboard_test.JSON](Grafana_dashboard_test.JSON).