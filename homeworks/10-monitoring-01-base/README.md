# Домашнее задание к занятию "10.01. Зачем и что нужно мониторить"

## Обязательные задания

1. Вас пригласили настроить мониторинг на проект. На онбординге вам рассказали, что проект представляет из себя 
платформу для вычислений с выдачей текстовых отчетов, которые сохраняются на диск. Взаимодействие с платформой 
осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы
выведите в мониторинг и почему?

2. Менеджер продукта посмотрев на ваши метрики сказал, что ему непонятно что такое RAM/inodes/CPUla. Также он сказал, 
что хочет понимать, насколько мы выполняем свои обязанности перед клиентами и какое качество обслуживания. Что вы 
можете ему предложить?

3. Вашей DevOps команде в этом году не выделили финансирование на построение системы сбора логов. Разработчики в свою 
очередь хотят видеть все ошибки, которые выдают их приложения. Какое решение вы можете предпринять в этой ситуации, 
чтобы разработчики получали ошибки приложения?

4. Вы, как опытный SRE, сделали мониторинг, куда вывели отображения выполнения SLA=99% по http кодам ответов. 
Вычисляете этот параметр по следующей формуле: summ_2xx_requests/summ_all_requests. Данный параметр не поднимается выше 
70%, но при этом в вашей системе нет кодов ответа 5xx и 4xx. Где у вас ошибка?

### Ответ

1. Минимальным набором метрик можно считать: <br>
    1.1. CPU load average (среднее по всем ядрам). Метрика необходима, т.к. вычисляения хорошо загружают CPU. Причем желательно выводить утилизацию за короткий период (среднее за 60сек). Неплохо было бы также вывести утилизацию по каждому из ядер, для контроля многопоточности. <br> 
    1.2. Утилизация дисковой подсистемы по емкости, т.к. запись выполняется на диск и необхожим контроль наличия свободного места. Можно также выполнить контроль свободной емкости по всем точкам монтирования. <br>
    1.3. Кол-во операций в секунду на дисковой подсистеме (ops в iostat) для контроля нагрузки на диск и выявления лимита в производительности. 
    1.4. Контроль уилизации RAM для обнаружения утечек в памяти и предотвращения ухода в swap (если он есть).<br>
    1.5. Контроль кол-ва HTTP запросов, % ответов с кодом 2xx.<br>

2. Для контроля качества обслуживания можно вывести метрики, макисмально близки к абоненту/пользователю, т.е.:<br>
    2.1. Процент HTTP ответов с кодом 2xx (возможно имеет смысл считать процент ответов 2xx + 3xx).<br>
    2.2. Кол-во запросов на формирование отчета.<br>
    2.3. Среднее время обработки запроса на формирование текстового отчета (время с момента нажатия кнопки "старт" до предоставления отчета клиенту).<br> 
    2.4. Соотношение кол-ва выполненных запросов на формирование отчета к кол-ву выполненных загрузок сформированных отчетов за период. Данная метрика может показать "полезность" и востребованность продукта (зависит от специфики продукта и реализации).<br>

3. Если нет финансирования, стоит рассмотреть бесплатные решения для сбора, обработки логов и их визуализации, например:<br>
    3.1. ELK стек. <br> 
    3.2. Агрегатор Grafana-loki/Promtail + визуализация Grafana.<br>
    3.3. Агрегатор Graylog + визуализация Graylog.<br>
    3.4. Аuрегатор Monq + визуализация Monq (импортозамещение привет).<br>

4. Ошибка скорее всего в том, что нет учета ошибок 3xx (redirect, moved и т.д.). Необходимо изменить формулу следующим образом `(summ_2xx_requests + summ_3xx_requests)/summ_all_requests`.<br>


## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Вы устроились на работу в стартап. На данный момент у вас нет возможности развернуть полноценную систему 
мониторинга, и вы решили самостоятельно написать простой python3-скрипт для сбора основных метрик сервера. Вы, как 
опытный системный-администратор, знаете, что системная информация сервера лежит в директории `/proc`. 
Также, вы знаете, что в системе Linux есть  планировщик задач cron, который может запускать задачи по расписанию.

Суммировав все, вы спроектировали приложение, которое:
- является python3 скриптом
- собирает метрики из папки `/proc`
- складывает метрики в файл 'YY-MM-DD-awesome-monitoring.log' в директорию /var/log 
(YY - год, MM - месяц, DD - день)
- каждый сбор метрик складывается в виде json-строки, в виде:
  + timestamp (временная метка, int, unixtimestamp)
  + metric_1 (метрика 1)
  + metric_2 (метрика 2)
  
     ...
     
  + metric_N (метрика N)
  
- сбор метрик происходит каждую 1 минуту по cron-расписанию

Для успешного выполнения задания нужно привести:<br>
а) работающий код python3-скрипта, <br>
б) конфигурацию cron-расписания, <br>
в) пример верно сформированного 'YY-MM-DD-awesome-monitoring.log', имеющий не менее 5 записей, <br>

P.S.: количество собираемых метрик должно быть не менее 4-х.
P.P.S.: по желанию можно себя не ограничивать только сбором метрик из `/proc`.

### Ответ

Сделаем после сдачи всех хвостов. Есть факт отставания от основной группы. 