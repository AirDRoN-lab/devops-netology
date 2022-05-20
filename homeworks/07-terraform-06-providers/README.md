# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   
2. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
    * Какая максимальная длина имени? 
    * Какому регулярному выражению должно подчиняться имя? 
  
### Ответ:
Resource перечислены в файле ./internal/provider/provider.go строка [896](https://github.com/hashicorp/terraform-provider-aws/blob/c3b5c746b140a795a8d47943689dfc3856db5a0a/internal/provider/provider.go#L896), 
а DataSource в строке [420](https://github.com/hashicorp/terraform-provider-aws/blob/c3b5c746b140a795a8d47943689dfc3856db5a0a/internal/provider/provider.go#L420).

Конфликтует c параметром name_prefix, в коде это можно найти в строке [87](https://github.com/hashicorp/terraform-provider-aws/blob/b7e860d4ea8003793b4f4c049301d8d7de86eeda/internal/service/sqs/queue.go#L87) файла terraform-provider-aws/internal/service/sqs/queue.go.

Что касается валидации и регулярного выражения, то в описании параметра name (как собвственно и name_prefix) валидации нет, т.е. нет функции ValidateFunc:   

```go
// DELETED
"name": {
			Type:          schema.TypeString,
			Optional:      true,
			Computed:      true,
			ForceNew:      true,
			ConflictsWith: []string{"name_prefix"},
		},
"name_prefix": {
			Type:          schema.TypeString,
			Optional:      true,
			Computed:      true,
			ForceNew:      true,
			ConflictsWith: []string{"name"},
// DELETED
```
Пример, где валидация например есть:
```go
// DELETED
"policy": {
			Type:             schema.TypeString,
			Optional:         true,
			Computed:         true,
			ValidateFunc:     validation.StringIsJSON,
			DiffSuppressFunc: verify.SuppressEquivalentPolicyDiffs,
			StateFunc: func(v interface{}) string {
				json, _ := structure.NormalizeJsonString(v)
				return json
			},
		},
// DELETED
```
Валидация Strings описана в файле https://github.com/hashicorp/terraform-plugin-sdk/blob/main/helper/validation/strings.go, например:

```go
// StringMatch returns a SchemaValidateFunc which tests if the provided value
// matches a given regexp. Optionally an error message can be provided to
// return something friendlier than "must match some globby regexp".
func StringMatch(r *regexp.Regexp, message string) schema.SchemaValidateFunc {
	return func(i interface{}, k string) ([]string, []error) {
		v, ok := i.(string)
		if !ok {
			return nil, []error{fmt.Errorf("expected type of %s to be string", k)}
		}

		if ok := r.MatchString(v); !ok {
			if message != "" {
				return nil, []error{fmt.Errorf("invalid value for %s (%s)", k, message)}

			}
			return nil, []error{fmt.Errorf("expected value of %s to match regular expression %q, got %v", k, r, i)}
		}
		return nil, nil
	}
}
```


## Задача 2. (Не обязательно) 
В рамках вебинара и презентации мы разобрали как создать свой собственный провайдер на примере кофемашины. 
Также вот официальная документация о создании провайдера: 
[https://learn.hashicorp.com/collections/terraform/providers](https://learn.hashicorp.com/collections/terraform/providers).

1. Проделайте все шаги создания провайдера.
2. В виде результата приложение ссылку на исходный код.
3. Попробуйте скомпилировать провайдер, если получится то приложите снимок экрана с командой и результатом компиляции.   

### Ответ:

Будет выполнена позже... без необходимости проверки
