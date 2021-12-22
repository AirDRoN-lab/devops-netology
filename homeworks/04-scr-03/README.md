# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"

## Обязательные задания

1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
{ "info" : "Sample JSON output from our service\t",
    "elements" :[
        { "name" : "first",
        "type" : "server",
        "ip" : 7175 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip : 71.78.22.43
        }
    ]
}
```

Нужно найти и исправить все ошибки, которые допускает наш сервис

### JSON исправленный 

```json
{ "info" : "Sample JSON output from our service\t",
    "elements" :
    [
        { "name" : "first",
        "type" : "server",
        "ip" : 7175
        },
        { "name" : "second",
        "type" : "proxy",
        "ip" : "71.78.22.43"
        }
    ]
}
```

2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

```python
import json
import socket
import time
import yaml

ipdb={}
domains=["drive.google.com", "mail.google.com", "google.com"]

for item in domains:
    ipdb.update({item : socket.gethostbyname(item)})

with open('IP.yaml', 'w') as ym1:
    for item in ipdb:
        pair = {item: ipdb[item]}
        ym1.write(" - ")
        ym1.write(yaml.dump(pair, default_flow_style=False))

with open('IP.json', 'w') as js1:
    for item in ipdb:
        pair = {item: ipdb[item]}
        js1.write(json.dumps(pair))
        js1.write("\n")

while (1 == 1):
    for item in ipdb:
        time.sleep(10)
        print("Cheсking...")
        iphost = socket.gethostbyname(item)
        if ipdb[item] != iphost:
            print("[ERROR] " + item + " IP mismatch: " + ipdb[item] + " " + iphost)
            ipdb[item]=iphost
            with open('IP.yaml', 'w') as ym1:
                for item in ipdb:
                    pair = {item: ipdb[item]}
                    ym1.write(" - ")
                    ym1.write(yaml.dump(pair, default_flow_style=False))

            with open('IP.json', 'w') as js1:
                for item in ipdb:
                    pair = {item: ipdb[item]}
                    js1.write(json.dumps(pair))
                    js1.write("\n")
```
Пример файла IP.json
```json
{"drive.google.com": "142.251.1.194"}
{"mail.google.com": "64.233.161.19"}
{"google.com": "142.251.1.102"}
```

Пример файла IP.yaml
```yaml
 - drive.google.com: 142.251.1.194
 - mail.google.com: 64.233.161.19
 - google.com: 142.251.1.102
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
Принимать на вход имя файла
Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
later
```