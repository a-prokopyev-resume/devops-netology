# [Домашнее задание](https://github.com/a-prokopyev-resume/sysadm-homeworks/tree/devsys10/04-script-02-py) к занятию ["Использование Python для решения типовых DevOps-задач"](https://netology.ru/profile/program/bash-dev-27/lessons/243371/lesson_items/1291932)

### Цель задания

В результате выполнения задания вы:

* познакомитесь с синтаксисом Python;
* узнаете, для каких типов задач его можно использовать;
* воспользуетесь несколькими модулями для работы с ОС.


### Инструкция к заданию

1. Установите Python 3 любой версии.
2. Скопируйте в свой .md-файл содержимое этого файла, исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-02-py/README.md).
3. Заполните недостающие части документа решением задач — заменяйте `???`, остальное в шаблоне не меняйте, чтобы не сломать форматирование текста, подсветку синтаксиса. Вместо логов можно вставить скриншоты по желанию.
4. Для проверки домашнего задания в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем репозитории.
4. Любые вопросы по выполнению заданий задавайте в чате учебной группы или в разделе «Вопросы по заданию» в личном кабинете.

### Дополнительные материалы

1. [Полезные ссылки для модуля «Скриптовые языки и языки разметки».](https://github.com/netology-code/sysadm-homeworks/tree/devsys10/04-script-03-yaml/additional-info)

------

## Задание 1

Есть скрипт:

```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:

| Вопрос  | Ответ                                                                              |
| ------------- |------------------------------------------------------------------------------------|
| Какое значение будет присвоено переменной `c`?  | undefined, потому что произойдет ошибка при сложении целого и строки.              |
| Как получить для переменной `c` значение 12?  | Нужно взять константу 1 в кавычки, чтобы переменная a получила строковое значение. |
| Как получить для переменной `c` значение 3?  | Нужно убрать кавычки вокруг константы 2, чтобы она стала целым числом. |
Либо можно использовать приведение типов с помощью функций `str` и `int`: `str(a)+b`, `a+int(b)`.

------

## Задание 2

Мы устроились на работу в компанию, где раньше уже был DevOps-инженер. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. 

Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

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

bash_command = ["cd ~/Homework", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
#is_change = False # unused variable
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
#       break # убираем преждевременный выход из цикла.
```

### Вывод скрипта при запуске во время тестирования:

```
23:06 alex@workstation ~/Homework/04-script-02-py 21:$ > ./test.py
03-sysadmin-09-security/README.md
03-sysadmin-09-security/firehol.conf
```

------

## Задание 3

Доработать скрипт выше так, чтобы он не только мог проверять локальный репозиторий в текущей директории, но и умел воспринимать путь к репозиторию, который мы передаём, как входной параметр. Мы точно знаем, что начальство будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:

```python
#!/usr/bin/env python3

import os;
import argparse;

parser = argparse.ArgumentParser(description="Python Homework 04-script-02-py",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter);
parser.add_argument("-p", "--path",  help="Specify path to a git repository");
args = vars(parser.parse_args());
project_path=args["path"];
bash_command = ["cd " + project_path, "git status"];
result_os = os.popen(' && '.join(bash_command)).read();
#print(result_os);
#is_change = False;
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '');
        print(prepare_result);
#        break;
```

### Вывод скрипта при запуске во время тестирования:

```
01:19 alex@workstation ~ 34:$ > Homework/04-script-02-py/test.py --path Homework
03-sysadmin-09-security/README.md
03-sysadmin-09-security/firehol.conf
```

------

## Задание 4

Наша команда разрабатывает несколько веб-сервисов, доступных по HTTPS. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. 

Проблема в том, что отдел, занимающийся нашей инфраструктурой, очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS-имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. 

Мы хотим написать скрипт, который: 

- опрашивает веб-сервисы; 
- получает их IP; 
- выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. 

Также должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена — оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:

Использовал файловую СУБД sqlite для сохранения истории всех ранее добавленных IP адресов.
Для упрощения работы с базой данных воспользовался ORM peewee, который в т.ч. и создает необходимую базу данных на основании декларации классов.

```python
#!/usr/bin/env python3
# '============================== The Beginning of the Copyright Notice ==========================================================
# ' The AUTHOR of this file is Alexander Borisovich Prokopyev born on December 20, 1977 resident of the city of Kurgan, Russia;
# ' Series and Russian passport number (only the last two digits for each one): **22-****91
# ' Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# ' Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# ' Copyright (C) Alexander B. Prokopyev, 2023, All Rights Reserved.
# ' Contact:      a.prokopyev.resume at gmail dot com
# '
# ' All source code contained in this file is protected by copyright law.
# ' This file is available under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
# ' PROVIDED FOLLOWING RESTRICTIONS APPLY:
# ' Nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content.
# ' Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# ' \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# ' specific language governing permissions and limitations under the License.
# '
# ' ATTENTION: If your country laws are not compatible or collide with this license terms you are prohibited to use this content.
# '================================= The End of the Copyright Notice =============================================================

import os,sys,socket;
import argparse;
import peewee,pickle;
parser = argparse.ArgumentParser(description="Python Homework 04-script-04-py",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter);
parser.add_argument("--action",  help="Specify: add or check.");
parser.add_argument("--hosts",  help="Specify host names delimited by commа to check.");
args = vars(parser.parse_args());
DB = peewee.SqliteDatabase("Hosts.db");
def InitDB():
    if __name__ == "__main__":
      try:
        Host.create_table();
#       DB.execute_sql("");
      except peewee.OperationalError:
        print("Hosts table already exists!");

class Host(peewee.Model):
    Name = peewee.CharField();
    IPAddress = peewee.CharField();
    @staticmethod
    def Add2(N, IP):
        NewHost=Host.create(Name=N, IPAddress=IP);
        NewHost.save();
    @staticmethod
    def Add(N):
        IP=socket.gethostbyname(N);
        try:
            Host.Add2(N,IP);
            print("Host " + N + ":" + IP + " saved to the database.");
        except:
            print("Could not save Host " + N + ":" + IP + " to the database, such pair already exists.");
    @staticmethod
    def FindSavedHosts(N):
        return Host.select().where(Host.Name == N);
    @staticmethod
    def Check(N):
        CurrentIP=socket.gethostbyname(N);
        print("===> Checking earlier IP addresses for the \thost: " + N + " \t\tIP: " + CurrentIP);
        IsMismatchFound=False;
        SHs=Host.FindSavedHosts(N);
        for H in SHs:
          if H.IPAddress != CurrentIP:
#            print("\tIP mismatch for  host: " + N + "; \tsaved IP: " + H.IPAddress + " \tcurrent IP: " + CurrentIP);
            print("\tERROR: IP mismatch found - saved IP: " + H.IPAddress);
            IsMismatchFound=True;
        if not IsMismatchFound:
          print("\tNo IP mismatches");  
    class Meta:
        database = DB;
        #constraints = [SQL('UNIQUE (Name, IPAddress)')];
        indexes = ( (('Name', 'IPAddress'), True), );

Action=args["action"]; 
# match args["action"]: # syntax missing in Python v3.9.x
if Action == "init":
  InitDB();   
else:
  try:
    Hosts=args["hosts"].split(",");
  except:
    print("Error: specify --hosts parameter delimited by commas");
  if Action == "add":
    for H in Hosts:
      Host.Add(H);
  elif Action == "check":
    for H in Hosts:
      Host.Check(H);
  else:
    print("Error: incorrent action specified!");
DB.close();
```

### Вывод скрипта при запуске во время тестирования:
Опция --init нужна для создания новой пустой базы данных.
Опция --add используется для добавления хостов, перечисленных в опции --hosts (разделенные запятыми), в базу данных.
Опция --check используется для сравнения текущих IP адресов хостов, перечисленных в опции --hosts (разделенные запятыми), с ранее сохраненными в базу.
```
16:29 root@chimaera /download/DevOps27 95:# > ./script4.py --action init;

16:29 root@chimaera /download/DevOps27 97:# > ls -al Hosts.db 
-rw-r--r-- 1 root root 12288 Jun 12 16:29 Hosts.db

16:30 root@chimaera /download/DevOps27 99:# > ./script4.py --action add --hosts $Hosts;
usage: script4.py [-h] [--action ACTION] [--hosts HOSTS]
script4.py: error: argument --hosts: expected one argument

16:30 root@chimaera /download/DevOps27 100:# > ./script4.py --action add --hosts "drive.google.com,mail.google.com,google.com"
Host drive.google.com:173.194.222.194 saved to the database.
Host mail.google.com:64.233.163.19 saved to the database.
Host google.com:108.177.14.138 saved to the database.

16:30 root@chimaera /download/DevOps27 101:# > ./script4.py --action add --hosts "drive.google.com,mail.google.com,google.com"
Could not save Host drive.google.com:173.194.222.194 to the database, such pair already exists.
Host mail.google.com:64.233.163.17 saved to the database.
Could not save Host google.com:108.177.14.138 to the database, such pair already exists.

16:30 root@chimaera /download/DevOps27 102:# > ./script4.py --action add --hosts "drive.google.com,mail.google.com,google.com"
Could not save Host drive.google.com:173.194.222.194 to the database, such pair already exists.
Could not save Host mail.google.com:64.233.163.19 to the database, such pair already exists.
Host google.com:108.177.14.102 saved to the database.

16:30 root@chimaera /download/DevOps27 103:# > ./script4.py --action add --hosts "drive.google.com,mail.google.com,google.com"
Could not save Host drive.google.com:173.194.222.194 to the database, such pair already exists.
Host mail.google.com:64.233.163.18 saved to the database.
Host google.com:108.177.14.100 saved to the database.

16:31 root@chimaera /download/DevOps27 104:# > ./script4.py --action add --hosts "drive.google.com,mail.google.com,google.com"
Could not save Host drive.google.com:173.194.222.194 to the database, such pair already exists.
Could not save Host mail.google.com:64.233.163.17 to the database, such pair already exists.
Could not save Host google.com:108.177.14.138 to the database, such pair already exists.

16:31 root@chimaera /download/DevOps27 105:# > ./script4.py --action check --hosts "drive.google.com,mail.google.com,google.com"
===> Checking earlier IP addresses for the      host: drive.google.com          IP: 173.194.222.194
        No IP mismatches
===> Checking earlier IP addresses for the      host: mail.google.com           IP: 64.233.163.17
        Error: IP mismatch found - saved IP: 64.233.163.18
        ERROR: IP mismatch found - saved IP: 64.233.163.19
===> Checking earlier IP addresses for the      host: google.com                IP: 108.177.14.139
        ERROR: IP mismatch found - saved IP: 108.177.14.100
        ERROR: IP mismatch found - saved IP: 108.177.14.102
        ERROR: IP mismatch found - saved IP: 108.177.14.138

16:33 root@chimaera /download/DevOps27 106:# > ./script4.py --action check --hosts "drive.google.com,mail.google.com,google.com"
===> Checking earlier IP addresses for the      host: drive.google.com          IP: 173.194.222.194
        No IP mismatches
===> Checking earlier IP addresses for the      host: mail.google.com           IP: 64.233.163.18
        ERROR: IP mismatch found - saved IP: 64.233.163.17
        ERROR: IP mismatch found - saved IP: 64.233.163.19
===> Checking earlier IP addresses for the      host: google.com                IP: 108.177.14.100
        ERROR: IP mismatch found - saved IP: 108.177.14.102
        ERROR: IP mismatch found - saved IP: 108.177.14.138

16:33 root@chimaera /download/DevOps27 107:# > ./script4.py --action check --hosts "drive.google.com,mail.google.com,google.com"
===> Checking earlier IP addresses for the      host: drive.google.com          IP: 173.194.222.194
        No IP mismatches
===> Checking earlier IP addresses for the      host: mail.google.com           IP: 64.233.163.19
        ERROR: IP mismatch found - saved IP: 64.233.163.17
        ERROR: IP mismatch found - saved IP: 64.233.163.18
===> Checking earlier IP addresses for the      host: google.com                IP: 108.177.14.138
        ERROR: IP mismatch found - saved IP: 108.177.14.100
        ERROR: IP mismatch found - saved IP: 108.177.14.102
```

### Правила приёма домашнего задания

В личном кабинете отправлена ссылка на .md-файл в вашем репозитории.

-----

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