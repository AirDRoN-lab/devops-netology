# Домашнее задание к занятию "10.02. Системы мониторинга"

## Обязательные задания

1. Опишите основные плюсы и минусы pull и push систем мониторинга.

### Ответ:

Push модель. Достоинства: 

    - Удобна для применения в динамически создаваемых VM и контейенарах, т.к. точка сбора метрик заранее известна. Значительно проще прописать логику для подключения к системе мониторинга (все логика подключения замкнута внутри данной ВМ/контейнера).
    - UDP протокол. Снижается обьем сигнального трафика и нагрузки на систему мониторинга (в теории).
    - Гибкая настройка отправки метрик.

Push модель. Недостатки:

    - Высокий риск потери данных при проблемах на сети или системе мониторинга. 

Pull модель. Достоинства: 

    - Единая точка конфигурации опрашиваемых хостов и списка метрик. Более высокий контроль над метриками. 
    - Высокий уровень контроля нагрузки системы мониторинга за счет управляемого распараллеливания процеса опроса. 
    - Есть возможность настроить proxy с TLS. Соответсвенно можно обеспечить безопасную передачу метрик. 

Pull модель. Недостатки:

    - Набор метрик ограничен функуионалом системы мониторинга.

2. Какие из ниже перечисленных систем относятся к push модели, а какие к pull? А может есть гибридные?

    - Prometheus 
    - TICK
    - Zabbix
    - VictoriaMetrics
    - Nagios

### Ответ:

    - Prometheus. Pull система. Хотя есть возможность настроить push gateway для сбора push метрик. Следует учитывать, что push gateway всеравно будет опрашиваться pull-методом с Prometheus.
    - TICK. Push система. В качестве агента на хосте используется telegraph, который пушит метрики в БД. 
    - Zabbix. Pull система. Все метрики Zabbix собирает сам непосредственно с хостов (snmp), либо с Zabbix агентов. 
    - VictoriaMetrics. Push модель. Служит приемущественно ддля хранения метрик. Взаимодейтсвие по API. Довольно часто работает в связке с Prometheus.
    - Nagios. Pull система. Опрос метрик по протоколу snmp с хостов.
    

3. Склонируйте себе [репозиторий](https://github.com/influxdata/sandbox/tree/master) и запустите TICK-стэк, 
используя технологии docker и docker-compose.(по инструкции ./sandbox up )

В виде решения на это упражнение приведите выводы команд с вашего компьютера (виртуальной машины):

    - curl http://localhost:8086/ping
    - curl http://localhost:8888
    - curl http://localhost:9092/kapacitor/v1/ping

А также скриншот веб-интерфейса ПО chronograf (`http://localhost:8888`). 

### Ответ

Вывод команд ниже, [скриншот](Tick_Chrono_screen.JPG) вложен в репозиторий.

```
vagrant@server2:~/REPO/sandbox$  curl http://localhost:8086/ping -v
*   Trying 127.0.0.1:8086...
* Connected to localhost (127.0.0.1) port 8086 (#0)
> GET /ping HTTP/1.1
> Host: localhost:8086
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 204 No Content
< Content-Type: application/json
< Request-Id: c1bb1cde-4919-11ed-809b-0242ac130003
< X-Influxdb-Build: OSS
< X-Influxdb-Version: 1.8.10
< X-Request-Id: c1bb1cde-4919-11ed-809b-0242ac130003
< Date: Tue, 11 Oct 2022 04:04:09 GMT
<
* Connection #0 to host localhost left intact
```
```
vagrant@server2:~/REPO/sandbox$ curl http://localhost:8888 -v
*   Trying 127.0.0.1:8888...
* Connected to localhost (127.0.0.1) port 8888 (#0)
> GET / HTTP/1.1
> Host: localhost:8888
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Accept-Ranges: bytes
< Cache-Control: public, max-age=3600
< Content-Length: 414
< Content-Security-Policy: script-src 'self'; object-src 'self'
< Content-Type: text/html; charset=utf-8
< Etag: ubyGAbz3Tc69bqd3w45d4WQtqoI=
< Vary: Accept-Encoding
< X-Chronograf-Version: 1.10.0
< X-Content-Type-Options: nosniff
< X-Frame-Options: SAMEORIGIN
< X-Xss-Protection: 1; mode=block
< Date: Tue, 11 Oct 2022 04:05:00 GMT
<
* Connection #0 to host localhost left intact
<!DOCTYPE html><html><head><link rel="stylesheet" href="/index.c708214f.css"><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>Chronograf</title><link rel="icon shortcut" href="/favicon.70d63073.ico"></head><body> <div id="react-root" data-basepath=""></div> <script type="module" src="/index.e81b88ee.js"></script><script src="/index.a6955a67.js" nomodule="" defer></script> </body></html>
```
```
vagrant@server2:~/REPO/sandbox$ curl http://localhost:9092/kapacitor/v1/ping -v
*   Trying 127.0.0.1:9092...
* Connected to localhost (127.0.0.1) port 9092 (#0)
> GET /kapacitor/v1/ping HTTP/1.1
> Host: localhost:9092
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 204 No Content
< Content-Type: application/json; charset=utf-8
< Request-Id: fc31036d-4919-11ed-80ae-0242ac130005
< X-Kapacitor-Version: 1.6.5
< Date: Tue, 11 Oct 2022 04:05:47 GMT
<
* Connection #0 to host localhost left intact
```

4. Изучите список [telegraf inputs](https://github.com/influxdata/telegraf/tree/master/plugins/inputs).
    - Добавьте в конфигурацию telegraf плагин - [disk](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/disk):
    ```
    [[inputs.disk]]
      ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
    ```
    - Так же добавьте в конфигурацию telegraf плагин - [mem](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/mem):
    ```
    [[inputs.mem]]
    ```
    - После настройки перезапустите telegraf.
 
    - Перейдите в веб-интерфейс Chronograf (`http://localhost:8888`) и откройте вкладку `Data explorer`.
    - Нажмите на кнопку `Add a query`
    - Изучите вывод интерфейса и выберите БД `telegraf.autogen`
    - В `measurments` выберите mem->host->telegraf_container_id , а в `fields` выберите used_percent. 
    Внизу появится график утилизации оперативной памяти в контейнере telegraf.
    - Вверху вы можете увидеть запрос, аналогичный SQL-синтаксису. 
    Поэкспериментируйте с запросом, попробуйте изменить группировку и интервал наблюдений.
    - Приведите скриншот с отображением
    метрик утилизации места на диске (disk->host->telegraf_container_id) из веб-интерфейса.  

### Ответ

[Скриншот](Tick_Chrono_DIskUsage.JPG) метрики утилизации места на диске, добавлено в дашборд.

Что добалвено в telegraf.conf:
```
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
[[inputs.mem]]
```
После чего выполнен перезапуск:

```
vagrant@server2:~/REPO/sandbox$ ./sandbox restart
Using latest, stable releases
Stopping all sandbox processes...
Starting all sandbox processes...
Services available!
```


5. Добавьте в конфигурацию telegraf следующий плагин - [docker](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/docker):
```
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
```

Дополнительно вам может потребоваться донастройка контейнера telegraf в `docker-compose.yml` дополнительного volume и 
режима privileged:
```
  telegraf:
    image: telegraf:1.4.0
    privileged: true
    volumes:
      - ./etc/telegraf.conf:/etc/telegraf/telegraf.conf:Z
      - /var/run/docker.sock:/var/run/docker.sock:Z
    links:
      - influxdb
    ports:
      - "8092:8092/udp"
      - "8094:8094"
      - "8125:8125/udp"
```

После настройки перезапустите telegraf, обновите веб интерфейс и приведите скриншотом список `measurments` в 
веб-интерфейсе базы telegraf.autogen . Там должны появиться метрики, связанные с docker.

Факультативно можете изучить какие метрики собирает telegraf после выполнения данного задания.

### Ответ

Для того чтобы запустить докер на последней версии Telegraf выполнено следующее:

Добавить в docker-compose.yml:
```
 telegraf:
    user: telegraf:998
```

Также добавлены inputs.socket_listener в telegraf.conf для ввода метрик вручную:
```
[[inputs.socket_listener]]
  service_address = "udp://:8094"
  data_format = "influx"
```

Пример добавления метрик:
```
echo "my_measurement,my_tag_key=my_tag_value value=1" | nc -u -4 -w 1 localhost 8094
echo "my_measurement,my_tag_key=my_tag_value value=2" | nc -u -4 -w 1 localhost 8094v
echo "my_measurement,my_tag_key=my_tag_value value=3" | nc -u -4 -w 1 localhost 8094v
echo "my_measurement,my_tag_key=my_tag_value value=10" | nc -u -4 -w 1 localhost 8094v
echo "my_measurement,my_tag_key=my_tag_value value=1" | nc -u -4 -w 1 localhost 8094v
echo "my_measurement,my_tag_key=my_tag_value value=10" | nc -u -4 -w 1 localhost 8094v
```

Скриншоты списка measurments и дашборда с метрикой кол-ва запущенных контейнеров: 
[скриншот1](Tick_Chrono_Docker.JPG)
[скриншот2](Tick_Chrono_Docker2.JPG)


## Дополнительное задание (со звездочкой*) - необязательно к выполнению

В веб-интерфейсе откройте вкладку `Dashboards`. Попробуйте создать свой dashboard с отображением:

    - утилизации ЦПУ
    - количества использованного RAM
    - утилизации пространства на дисках
    - количество поднятых контейнеров
    - аптайм
    - ...
    - фантазируйте)
    
    ---
### Ответ

Фактически выполнено, но есть вопрос по преобразованию uptime в timestamp в нормальный формат и реально ли это сделать средствами TICK?
Вывел в timestamp: [скриншот2](Tick_Chrono_Docker2.JPG)
