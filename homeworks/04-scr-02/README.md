# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | никакой, нельзя суммировать int+str  |
| Как получить для переменной `c` значение 12?  | сделать переменную a, строковой. Т.е. c = str(a) + b | # исправлено
| Как получить для переменной `c` значение 3?  | сделать переменную b, целочисленной. Т.е. c = a + int(b)  | # исправлено

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

path='c:\\Users\\dmgol\\PycharmProjects\\DEVSYS\\devops-netology\\homeworks\\'
shell_command = ['cd '+path, 'git status']
result_os = os.popen(' && '.join(shell_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = path+result.replace('\tmodified:   ', '')
        print(prepare_result.replace('/','\\'))
```

### Вывод скрипта при запуске при тестировании:
```
c:\Users\dmgol\PycharmProjects\DEVSYS\devops-netology\homeworks\04-scr-02\README.md
c:\Users\dmgol\PycharmProjects\DEVSYS\devops-netology\homeworks\04-scr-02\README.md.bak
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys

path=sys.argv[1]
shell_command = ['cd '+path, 'git status']
result_os = os.popen(' && '.join(shell_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = path+result.replace('\tmodified:   ', '')
        print(prepare_result.replace('/','\\'))
```

### Вывод скрипта при запуске при тестировании:
```
c:\Users\dmgol\PycharmProjects\DEVSYS\devops-netology\homeworks\04-scr-02\README.md
c:\Users\dmgol\PycharmProjects\DEVSYS\devops-netology\homeworks\04-scr-02\README.md.bak
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import time

oldip={}

domains=["drive.google.com", "mail.google.com", "google.com"]
for item in domains:
    oldip[item] = socket.gethostbyname(item)

while True: #исправлено с (1 == 1)
    print("Cheсking...")
    for item in oldip:
        iphost = socket.gethostbyname(item)
        if oldip[item] != iphost:
            print("[ERROR] "+item+" IP mismatch: "+oldip[item]+" "+iphost)
            exit(0)
    time.sleep(10)
```

### Вывод скрипта при запуске при тестировании:
```
Cheсking...
Cheсking...
Cheсking...
[ERROR] drive.google.com IP mismatch: 142.250.150.194 64.233.165.194
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 

### Ваш скрипт:
```python
import requests
import json
import sys
import os
import time

username = "AirDRoN-lab"
repo = "devops-netology-1"
token = "ghp_f3dXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

msg=sys.argv[1]
path=sys.argv[2]
branch="br"+time.strftime("%Y%m%d%H%M%S")

shell_command = ['cd '+path, 'git branch '+branch, 'git checkout '+branch, 'git add *', 'git commit -m "'+msg+'"', 'git push  --set-upstream origin '+branch]
os.popen(' && '.join(shell_command)).read()

task = input ("Create PR? (y/n) \n: ")
if task == "y" or task == "Y":
    url = "https://api.github.com/repos/{}/{}/pulls".format(username, repo)
    headers = {
        "Authorization": "token {}".format(token),
    }
    data = {
      "title": "PULL request "+branch,
      "body": "PR from path: "+path+" (from API)",
      "head": branch,
      "base": "main"
    }
    req = requests.post(url,data=json.dumps(data), headers=headers)
    if req.status_code == "201":
        exit(0)
    else:
        exit(1)
```

### Вывод скрипта при запуске при тестировании:
```
C:\Users\dmgol\PycharmProjects\DEVSYS\Github_PR\venv\Scripts\python.exe C:/Users/dmgol/PycharmProjects/DEVSYS/Github_PR/main.py TEST_MSG 
Switched to branch 'br20220110004109'
remote: 
remote: Create a pull request for 'br20220110004109' on GitHub by visiting:        
remote:      https://github.com/AirDRoN-lab/devops-netology-1/pull/new/br20220110004109        
remote: 
To https://github.com/AirDRoN-lab/devops-netology-1.git
 * [new branch]      br20220110004109 -> br20220110004109
Create PR? (y/n) 
: y

Process finished with exit code 0

```