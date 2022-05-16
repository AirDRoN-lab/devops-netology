# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```
 
2. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код. 

### Ответ

Задача1:
```go
package main

import "fmt"

func main() {
	fmt.Print("Enter number of meters to convert to feet: ")
	var input float64 = 10
	fmt.Scanf("%f", &input)
	output := input / 0.3048
	fmt.Println("Thr result is: ", output)
}
```
Результат:
```
C:\Users\Documents\_Projects\Gotest>go run main.go
Enter number of meters to convert to feet: 50
164.04199475065616
```
Задача2 (вариант 1):
```go
package main

import (
	"fmt"
	"sort"
)

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	sort.Ints(x)
	fmt.Println("The result is: ", x[0])
}
```
Результат:
```
C:\Users\Documents\_Projects\Gotest>go run main.go
The result is:  9
```
Задача2 (вариант 2):
```go
package main

import (
	"fmt"
)

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	var length = len(x)
	min := x[0]
	for k := 0; k < length-1; k++ {
		if min > x[k+1] {
			min = x[k+1]
		}
	}
	fmt.Println("The min value is: ", min)
}
```
Результат:
```
C:\Users\Documents\_Projects\Gotest>go run main.go
The min value is: 9
```

Задача3:
```go
package main

import "fmt"

func main() {
	x := make([]int, 0)
	for k := 1; k < 100; k++ {
		//fmt.Println("The result is", k)
		if k%3 == 0 {
			x = append(x, k)
		}
	}
	fmt.Println("The result is: ", x)
}
```
Результат:
```
C:\Users\Documents\_Projects\Gotest>go run main.go
The result is:  [3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 72 75 78 81 84 87 90 93 96 99]
```

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 



