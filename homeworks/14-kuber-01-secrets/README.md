# Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
задачу 1 как справочный материал.

## Поготовка к ДЗ

Для выполнения домашнего задания используем не миникуб, а домашний экспериментальный кластер.

## Как создать секрет?

```
openssl genrsa -out cert.key 4096
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
```

### Выполнение команд

Создадим сертификат и ключ и поместим их в kuber (сущность Secret).

```
dgolodnikov@pve-vm1:~$ openssl genrsa -out cert.key 4096
dgolodnikov@pve-vm1:~$ ls -la cert.key
-rw------- 1 dgolodnikov dgolodnikov 3272 дек 25 12:13 cert.key
dgolodnikov@pve-vm1:~$ cat cert.key
-----BEGIN PRIVATE KEY-----
MIIJQgIBADANBgkqhkiG9w0BAQEFAASCCSwwggkoAgEAAoICAQDDmldoYgae60Kf
MYuDH826OhWUObXbObb9ze00577vinb6TJfBgn9Z5HuznNxsCtaIZ6oEvzactXoT
...
2O7PnEHAs0xPxQiXXv8J8wxflXuWOLwFwCq9TomcE1lymSxNoK9b8hnWMwuv7BaH
sx7l4Q8NAVPW6In1dJ0x/Neo6nRHmN/V5PolAiXe5OdIX3VRpWZgnn5sjvOFlkxh
LFg07NebXcMlC7qySL06cvI8mVpgHA==
-----END PRIVATE KEY-----
```
```
dgolodnikov@pve-vm1:~$ openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
dgolodnikov@pve-vm1:~$ ls -la cert.crt
-rw-rw-r-- 1 dgolodnikov dgolodnikov 1944 дек 25 12:15 cert.crt
dgolodnikov@pve-vm1:~$ cat cat cert.crt
cat: cat: No such file or directory
-----BEGIN CERTIFICATE-----
MIIFbTCCA1WgAwIBAgIUee3CjTpggaLsn+74RBHMe/cOKxUwDQYJKoZIhvcNAQEL
BQAwRjELMAkGA1UEBhMCUlUxDzANBgNVBAgMBk1vc2NvdzEPMA0GA1UEBwwGTW9z
Y293MRUwEwYDVQQDDAxzZXJ2ZXIubG9jYWwwHhcNMjIxMjI1MTIxNTI3WhcNMzIx
...
dc1Xzkcz5lstW8xHv7xfUg8TjQBfrK1J9kTlwD5Dh9kvArs7hq5PuoSmSw9GwsTQ
rbzzD9ES/0yJGtwUGUjl97GgjN3MZUu9StRyoFg7z2A+gptNwuKDInu8cY0He9+W
7DWgj5dTVRnjPyiRHAM9djjb8ikYfQZhw01XJiHjuOAbxJO5zlRi/cKm/Yqz/V1Y
yg==
-----END CERTIFICATE-----
```
```
dgolodnikov@pve-vm1:~$ kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
secret/domain-cert created
```

## Как просмотреть список секретов?

```
kubectl get secrets
kubectl get secret
```

### Выполнение команд

```
dgolodnikov@pve-vm1:~$ kubectl get secret
NAME                               TYPE                 DATA   AGE
domain-cert                        kubernetes.io/tls    2      3m5s
sh.helm.release.v1.nfs-server.v1   helm.sh/release.v1   1      6d19h

```

## Как просмотреть секрет?

```
kubectl get secret domain-cert
kubectl describe secret domain-cert
```

### Выполнение комманд:
```
dgolodnikov@pve-vm1:~$ kubectl get secret domain-cert
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      61s

dgolodnikov@pve-vm1:~$ kubectl describe secret domain-cert
Name:         domain-cert
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.key:  3272 bytes
tls.crt:  1944 bytes

```

## Как получить информацию в формате YAML и/или JSON?

```
kubectl get secret domain-cert -o yaml
kubectl get secret domain-cert -o json
```
### Выполнение команд

Yaml:
```
dgolodnikov@pve-vm1:~$ kubectl get secret domain-cert -o yaml
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZiVENDQTFXZ0F3SUJBZ0lVZWUzQ2pUcGdnYUxzbis3NFJCSE1lL2NPS3hVd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1JqRUxNQWtHQTFVRUJoTUNVbFV4RHpBTkJnTlZCQWdNQmsxdmMyTnZkekVQTUEwR0ExVUVCd3dHVFc5egpZMjkzTVJVd0V3WURWUVFE
  ...
  lpUkhBTTlkampiOGlrWWZRWmh3MDFYSmlIanVPQWJ4Sk81emxSaS9jS20vWXF6L1YxWQp5Zz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRRERtbGRvWWdh...
  ZWJYY01sQzdxeVNMMDZjdkk4bVZwZ0hBPT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=
kind: Secret
metadata:
  creationTimestamp: "2022-12-25T12:19:16Z"
  name: domain-cert
  namespace: default
  resourceVersion: "2021179"
  uid: e659f68b-33e4-4e01-8037-a74f02a70166
type: kubernetes.io/tls

```

JSON:
```
dgolodnikov@pve-vm1:~$ kubectl get secret domain-cert -o json
{
    "apiVersion": "v1",
    "data": {
        "tls.crt": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZiVENDQTFXZ0F3SUJBZ0lVZWUzQ2pUcGdnYUxzbis3NFJCSE1lL2NPS3hVd0RRWUpLb
        ...
        rWWZRWmh3MDFYSmlIanVPQWJ4Sk81emxSaS9jS20vWXF6L1YxWQp5Zz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
        "tls.key": "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRRERtb
        ...
        RJWDNWUnBXWmdubjVzanZPRmxreGgKTEZnMDdOZWJYY01sQzdxeVNMMDZjdkk4bVZwZ0hBPT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo="
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2022-12-25T12:19:16Z",
        "name": "domain-cert",
        "namespace": "default",
        "resourceVersion": "2021179",
        "uid": "e659f68b-33e4-4e01-8037-a74f02a70166"
    },
    "type": "kubernetes.io/tls"
}
```

## Как выгрузить секрет и сохранить его в файл?

```
kubectl get secrets -o json > secrets.json
kubectl get secret domain-cert -o yaml > domain-cert.yml
```

### Выполнение команд

```
dgolodnikov@pve-vm1:~/certs$ kubectl get secrets -o json > secrets.json
dgolodnikov@pve-vm1:~/certs$ kubectl get secret domain-cert -o yaml > domain-cert.yml

dgolodnikov@pve-vm1:~/certs$ ls -la
total 56
drwxrwxr-x  2 dgolodnikov dgolodnikov  4096 дек 25 12:35 .
drwxr-x--- 17 dgolodnikov dgolodnikov  4096 дек 25 12:19 ..
-rw-rw-r--  1 dgolodnikov dgolodnikov  1944 дек 25 12:15 cert.crt
-rw-------  1 dgolodnikov dgolodnikov  3272 дек 25 12:13 cert.key
-rw-rw-r--  1 dgolodnikov dgolodnikov  7206 дек 25 12:35 domain-cert.yml
-rw-rw-r--  1 dgolodnikov dgolodnikov 29488 дек 25 12:35 secrets.json
```

## Как удалить секрет?

```
kubectl delete secret domain-cert
```
### Выполнение команды:
```
dgolodnikov@pve-vm1:~/certs$ kubectl delete secret domain-cert
secret "domain-cert" deleted
```

## Как загрузить секрет из файла?

```
kubectl apply -f domain-cert.yml
```

### Выполнение команды:
```
dgolodnikov@pve-vm1:~/certs$ kubectl apply -f domain-cert.yml
secret/domain-cert created

```

## Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
как в виде переменных окружения, так и в виде примонтированного тома.

## Ответ

Ради эксперимента решил  прогрузить созданные секрет в переменные окружения внутрь пода (т.к. задача1 совсем не задача. Секреты создали, а как использовать не понятно). В итоге в манифест были добавлены следующие строки:

```
- name: SECRET_TLSCRT
          valueFrom:
            secretKeyRef:
              name: domain-cert
              key: tls.crt
        - name: SECRET_TLSKEY
          valueFrom:
            secretKeyRef:
              name: domain-cert
              key: tls.key
```
Полная версия манифеста выложена [здесь](manifests/10-task2_pods_w_secrets.yaml).

Проверяем наличие переменных окружения:
```
dgolodnikov@pve-vm1:~$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
front-64c764d947-8l65x                1/1     Running   0          4m49s
nfs-server-nfs-server-provisioner-0   1/1     Running   0          6d19h

dgolodnikov@pve-vm1:~$ kubectl exec -it front-64c764d947-8l65x -- printenv | grep -A2 SECRET
SECRET_TLSCRT=-----BEGIN CERTIFICATE-----
MIIFbTCCA1WgAwIBAgIUee3CjTpggaLsn+74RBHMe/cOKxUwDQYJKoZIhvcNAQEL
BQAwRjELMAkGA1UEBhMCUlUxDzANBgNVBAgMBk1vc2NvdzEPMA0GA1UEBwwGTW9z
--
  SECRET_TLSKEY=-----BEGIN PRIVATE KEY-----
MIIJQgIBADANBgkqhkiG9w0BAQEFAASCCSwwggkoAgEAAoICAQDDmldoYgae60Kf
MYuDH826OhWUObXbObb9ze00577vinb6TJfBgn9Z5HuznNxsCtaIZ6oEvzactXoT
```

Переменные окружения на месте, значения есть. Все ок. 