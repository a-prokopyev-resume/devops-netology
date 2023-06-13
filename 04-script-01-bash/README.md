# [Домашнее задание](https://github.com/a-prokopyev-resume/sysadm-homeworks/tree/devsys10/04-script-01-bash) к занятию [«Командная оболочка Bash: Практические навыки»](https://netology.ru/profile/program/bash-dev-27/lessons/243370/lesson_items/1291924)

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
Пример запуска:
```
+ Hosts='173.194.222.113 192.168.0.1 87.250.250.242'
+ Port=80
+ Options=' --connect-timeout 3  --max-time 4 '
+ for H in $Hosts
+ check_availability 173.194.222.113
+ Address=173.194.222.113
+ Times=1
+ (( i=1 ))
+ (( i<=Times ))
+ rm -f good_pass.log
+ rm -f bad_pass.log
+ curl -v --connect-timeout 3 --max-time 4 --output good_pass.log --stderr bad_pass.log http://173.194.222.113:80
+ Result=0
+ cat good_pass.log
+ cat bad_pass.log
++ date
+ echo -ne 'Tue 13 Jun 2023 11:26:39 AM +05 :   \t'
+ (( Result == 0  ))
+ echo 'Test N:1 of address 173.194.222.113 passed. Exit code: 0'
+ (( i++ ))
+ (( i<=Times ))
+ Result2=0
+ ((  0 == 1  ))
+ for H in $Hosts
+ check_availability 192.168.0.1
+ Address=192.168.0.1
+ Times=1
+ (( i=1 ))
+ (( i<=Times ))
+ rm -f good_pass.log
+ rm -f bad_pass.log
+ curl -v --connect-timeout 3 --max-time 4 --output good_pass.log --stderr bad_pass.log http://192.168.0.1:80
+ Result=28
+ cat good_pass.log
cat: good_pass.log: No such file or directory
+ cat bad_pass.log
++ date
+ echo -ne 'Tue 13 Jun 2023 11:26:42 AM +05 :   \t'
+ (( Result == 0  ))
+ echo 'Test N:1 of address 192.168.0.1 failed. Exit code: 28'
+ (( Times==1 ))
+ return 1
+ Result2=1
+ ((  1 == 1  ))
+ echo 'Check failed, exiting ...'
Check failed, exiting ...
+ exit 1
```
Содержимое лог файла:
```
Tue 13 Jun 2023 11:26:39 AM +05 :       Test N:1 of address 173.194.222.113 passed. Exit code: 0
Tue 13 Jun 2023 11:26:42 AM +05 :       Test N:1 of address 192.168.0.1 failed. Exit code: 28
```

---

## Задание со звёздочкой* 

Это самостоятельное задание, его выполнение необязательно.
____

Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для Git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках, и количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.

### Ваш скрипт:

Создаем файл `.git/hooks/commit-msg` со следующим содержимым:
```bash
#!/bin/bash

MessageFile="$1";
echo -n "Message: "; cat $MessageFile;
echo -e "\nTesting ...";

if ! grep --silent --perl-regexp '^.{3,30}$' $MessageFile; then
        echo "Your message has incorrect size (most likely it is too long)";
        exit 1;
fi;

if ! grep --silent --perl-regexp '^\[\d{1,2}-.{1,15}-\d{1,2}-.{1,15}\]\s.{1,25}$' $MessageFile; then
        echo "Your message does not match the pattern: [nn-xxx-nn-yyy] zzz";
        exit 2;
fi;

echo "Good commit message";
exit 0;
```

Тестируем скрипт на разных входных данных:
```
11:22 root@workstation /home/alex/Homework/04-script-01-bash 270:# > ./script5.sh bad_test.txt
Message: [04-script-01-bash] Bad because it is too long.
Testing ...
Your message is too long

11:22 root@workstation /home/alex/Homework/04-script-01-bash 271:# > ./script5.sh bad_test2.txt
Message: [04x-script-01y-bash] Bad N2.
Testing ...
Your message does not match the pattern: [nn-xxx-nn-yyy] zzz

11:22 root@workstation /home/alex/Homework/04-script-01-bash 272:# > ./script5.sh good_test.txt
Message: [04-script-01-bash] Good.
Testing ...
Good commit message
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
