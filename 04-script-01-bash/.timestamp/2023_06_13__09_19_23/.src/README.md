# Домашнее задание к занятию «Командная оболочка Bash: Практические навыки»

### Цель задания

В результате выполнения задания вы:

* познакомитесь с командной оболочкой Bash;
* используете синтаксис bash-скриптов;
* узнаете, как написать скрипт в файл так, чтобы он мог выполниться с параметрами и без.


### Чеклист готовности к домашнему заданию

1. У вас настроена виртуальная машина, контейнер или установлена гостевая ОС семейств Linux, Unix, MacOS.
2. Установлен Bash.


### Инструкция к заданию

1. Скопируйте в свой .md-файл содержимое этого файла, исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-01-bash/README.md).
2. Заполните недостающие части документа решением задач — заменяйте `???`, остальное в шаблоне не меняйте, чтобы не сломать форматирование текста, подсветку синтаксиса. Вместо логов можно вставить скриншоты по желанию.
3. Для проверки домашнего задания в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем репозитории.
4. Любые вопросы по выполнению заданий задавайте в чате учебной группы или в разделе «Вопросы по заданию» в личном кабинете.

### Дополнительные материалы

1. [Полезные ссылки для модуля «Скриптовые языки и языки разметки».](https://github.com/netology-code/sysadm-homeworks/tree/devsys10/04-script-03-yaml/additional-info)

------

## Задание 1

Есть скрипт:

```bash
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```

Какие значения переменным c, d, e будут присвоены? Почему?

| Переменная  | Значение | Обоснование |
| ------------- | ------------- | ------------- |
| `c`  | a+b  | Строка "a+b", которая указана для присваивания |
| `d`  | 1+2  | Вместо переменных $a и $b будут подставлены их значения |
| `e`  | 3    | Конструкция $(( выражение )) задает арифметический контекст для вычисления выражения внутри скобок |

----

## Задание 2

На нашем локальном сервере упал сервис, и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным. После чего скрипт должен завершиться. 

В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на жёстком диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:

```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```

### Ваш скрипт:

```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	else
		exit 0;
	fi
done
```
---

## Задание 3

Необходимо написать скрипт, который проверяет доступность трёх IP: `192.168.0.1`, `173.194.222.113`, `87.250.250.242` по `80` порту и записывает результат в файл `log`. Проверять доступность необходимо пять раз для каждого узла.

### Ваш скрипт:

```bash

set -x;

Hosts="173.194.222.113 192.168.0.1 87.250.250.242";
Port=80;

Options=" --connect-timeout 3  --max-time 4 ";

check_availability()
{
        Address=$1;
        Times=${2:-1};
        for ((i=1; i<=Times; i++));
        do
                rm -f good_pass.log; rm -f bad_pass.log;
                #timeout 3s 
                curl -v $Options --output good_pass.log --stderr bad_pass.log http://$Address:$Port; # 2>&1 >> output.log;
                Result=$?;
                cat good_pass.log >> good_output.log; cat bad_pass.log >> error_output.log;
                echo -ne "$(date) :   \t" >> log;
                if ((Result == 0 )); then
                        echo "Test N:$i of address $Address passed. Exit code: $Result" >> log;
                else
                        echo "Test N:$i of address $Address failed. Exit code: $Result" >> log;
                        if ((Times==1)); then
                                return 1;
                        fi;
                fi;
        done;
}

for H in $Hosts; do
       check_availability $H 5;
done;

```

---
## Задание 4

Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен — IP этого узла пишется в файл error, скрипт прерывается.

### Ваш скрипт:

Далее фрагмент кода, который вызывает функцию `check_availability` из предыдущей задачи:

```bash
for H in $Hosts; do
        check_availability $H;
        Result2=$?;
        if (( $Result2 == 1 )); then
                echo "Check failed, exiting ...";
                exit 1;
        fi;
done;
```

---

## Задание со звёздочкой* 

Это самостоятельное задание, его выполнение необязательно.
____

Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для Git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках, и количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.

### Ваш скрипт:

Создаем файл`12:# > joe .git/hooks/commit-msg` со следующим содержимым:
```bash
MessageFile=$1;
grep --perl-regexp '^\[.{1,5}\].{1,25}$' $MessageFile | grep --perl-regexp '^.{3,30}$'
```

----

### Правила приёма домашнего задания

В личном кабинете отправлена ссылка на .md-файл в вашем репозитории.


### Критерии оценки

Зачёт:

* выполнены все задания;
* ответы даны в развёрнутой форме;
* приложены соответствующие скриншоты и файлы проекта;
* в выполненных заданиях нет противоречий и нарушения логики.

На доработку:

* задание выполнено частично или не выполнено вообще;
* в логике выполнения заданий есть противоречия и существенные недостатки.  
 
Обязательными являются задачи без звёздочки. Их выполнение необходимо для получения зачёта и диплома о профессиональной переподготовке.

Задачи со звёздочкой (*) являются дополнительными или задачами повышенной сложности. Они необязательные, но их выполнение поможет лучше разобраться в теме.
