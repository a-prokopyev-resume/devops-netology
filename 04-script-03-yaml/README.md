# [Домашнее задание](https://github.com/a-prokopyev-resume/sysadm-homeworks/tree/devsys10/04-script-03-yaml) к занятию [«Языки разметки JSON и YAML»](https://netology.ru/profile/program/bash-dev-27/lessons/243372/lesson_items/1291940)

### Цель задания

В результате выполнения задания вы:

* познакомитесь с синтаксисами JSON и YAML;
* узнаете, как преобразовать один формат в другой при помощи пары строк.

### Чеклист готовности к домашнему заданию

1. Установлена библиотека PyYAML для Python 3.

### Инструкция к заданию 

1. Скопируйте в свой .md-файл содержимое этого файла, исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-03-yaml/README.md).
3. Заполните недостающие части документа решением задач — заменяйте `???`, остальное в шаблоне не меняйте, чтобы не сломать форматирование текста, подсветку синтаксиса. Вместо логов можно вставить скриншоты по желанию.
4. Любые вопросы по выполнению заданий задавайте в чате учебной группы или в разделе «Вопросы по заданию» в личном кабинете.

### Дополнительные материалы

1. [Полезные ссылки для модуля «Скриптовые языки и языки разметки».](https://github.com/netology-code/sysadm-homeworks/tree/devsys10/04-script-03-yaml/additional-info)

------

## Задание 1

Мы выгрузили JSON, который получили через API-запрос к нашему сервису:

```
 { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис.

### Ваш скрипт:

```
    {
    	"info": "Sample JSON output from our service\t",
    	"elements": [{
    			"name": "first",
    			"type": "server",
    			"ip": "7.1.7.5"
    		},
    		{
    			"name": "second",
    			"type": "proxy",
    			"ip": "71.78.22.43"
    		}
    	]
    }
```

Проходит проверку в JSONLint.

---

## Задание 2

В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML-файлов, описывающих наши сервисы. 

Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. 

Формат записи YAML по одному сервису: `- имя сервиса: его IP`. 

Если в момент исполнения скрипта меняется IP у сервиса — он должен так же поменяться в YAML и JSON-файле.

### Ваш скрипт:

В скрипт из предыдущей работы добавил функцию `save_new_hosts()`, которая использует модули `json` и `yaml` для сериализации списка HostList.

```python
import os,sys,socket;
import argparse;
import peewee,pickle;
import json, yaml;

parser = argparse.ArgumentParser(description="Python Homework 04-script-04-py",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter);
parser.add_argument("--action",  help="Specify: add or check.");
parser.add_argument("--hosts",  help="Specify host names delimited by commа to check.");
args = vars(parser.parse_args());


DB = peewee.SqliteDatabase("hosts.db");
#HostDict = {};
HostList = [];

def save_new_hosts():
  with open("hosts.json", "w") as J:
    json.dump(HostList, J, indent=2);
  with open("hosts.yaml", "w") as Y:
    yaml.dump(HostList, Y, explicit_start=True, explicit_end=True);

def InitDB():
    if __name__ == "__main__":
      try:
        Host.create_table();
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
        #HostDict[N] = CurrentIP;
        HostList.append({N: CurrentIP});
        print("===> Checking earlier IP addresses for the \thost: " + N + " \t\tIP: " + CurrentIP);
        IsMismatchFound=False;
        SHs=Host.FindSavedHosts(N);
        for H in SHs:
          if H.IPAddress != CurrentIP:
            print("\tIP mismatch found - saved IP: " + H.IPAddress);
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
    save_new_hosts();
  else:
    print("Error: incorrent action specified!");

DB.close();
sys.exit(0);

```

### Вывод скрипта при запуске во время тестирования:

```
18:10 root@chimaera /download/1 36:# > ./script2.py --action check --hosts "drive.google.com,mail.google.com,google.com"
===> Checking earlier IP addresses for the      host: drive.google.com          IP: 173.194.222.194
        No IP mismatches
===> Checking earlier IP addresses for the      host: mail.google.com           IP: 64.233.163.18
        IP mismatch found - saved IP: 64.233.163.17
        IP mismatch found - saved IP: 64.233.163.83
===> Checking earlier IP addresses for the      host: google.com                IP: 108.177.14.113
        IP mismatch found - saved IP: 108.177.14.102
        IP mismatch found - saved IP: 108.177.14.138

18:10 root@chimaera /download/1 37:# > ls
hosts.db  hosts.json  hosts.yaml  script2.py  script2.py~

```

### JSON-файл(ы), который(е) записал ваш скрипт:

`18:10 root@chimaera /download/1 38:# > cat hosts.json `:

```json
[
  {
    "drive.google.com": "173.194.222.194"
  },
  {
    "mail.google.com": "64.233.163.18"
  },
  {
    "google.com": "108.177.14.113"
  }
]
```

### YAML-файл(ы), который(е) записал ваш скрипт:

`18:11 root@chimaera /download/1 39:# > cat hosts.yaml`:

```yaml
---
- drive.google.com: 173.194.222.194
- mail.google.com: 64.233.163.18
- google.com: 108.177.14.113
...
```

---

## Задание со звёздочкой* 

Это самостоятельное задание, его выполнение необязательно.
____

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:

   * принимать на вход имя файла;
   * проверять формат исходного файла. Если файл не JSON или YAML — скрипт должен остановить свою работу;
   * распознавать, какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны;
   * перекодировать данные из исходного формата во второй доступный —  из JSON в YAML, из YAML в JSON;
   * при обнаружении ошибки в исходном файле указать в стандартном выводе строку с ошибкой синтаксиса и её номер;
   * полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов.

### Ваш скрипт:

Скрипт использует библиотеку ruamel.yaml для работы с YAML v1.2, который полностью поддерживает JSON в качестве своего подмножества.  
Поэтому проверять исходный формат файла ненужно, кроме случаев его полной невалидности в любом из форматов JSON или YAML.  
Скрипт читает входной файл, указанный в опции `--source` и выводит результат в файл, указанный в опции `--destination`.  
Если опция `--destination` не указана, то вывод происходит в stdout т.е. в терминал.  
Опция `--to` указывает формат ожидаемого результата работы скрипта: `json` или `yaml`.  

Немного отклонился от условий задачи, потому что задача необязательная (все это легко переделать, но я пока сделал так, как мне удобнее):
   * проверять формат исходного файла. Если файл не JSON или YAML — скрипт должен остановить свою работу;
     * Вероятно вылетит exception с нужной информацией
   * перекодировать данные из исходного формата во второй доступный —  из JSON в YAML, из YAML в JSON;
     * У меня нужно указывать формат результата явно опцией `--to`.
   * при обнаружении ошибки в исходном файле указать в стандартном выводе строку с ошибкой синтаксиса и её номер;
     * Вероятно вылетит exception с нужной информацией
   * полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов.
     * Имена файлов у меня задаются явно опциями `--source` и `--destination`.  

`21:02 root@chimaera /download/1 32:# > cat convertor.py`

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

import argparse;
import json, ruamel.yaml;
import sys;

parser = argparse.ArgumentParser(description="Python Homework 04-script-04-yaml",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter);
parser.add_argument("--to",  help="Specify: json or yaml.");
parser.add_argument("--source",  help="Specify input file.");
parser.add_argument("--destination",  help="Specify output file.");
args = vars(parser.parse_args());

SourceFile=args["source"];
if not SourceFile is None:
  try:
    Y = ruamel.yaml.YAML(typ='safe');
    SF=open(SourceFile);
    Data = Y.load(SF);
  except:
    print("Error: Could not open input file specified by --source option!");
    exit(1);

DestinationFile=args["destination"];
global DF;
if DestinationFile is None:
   DF=sys.stdout; 
else:
  DF=open(DestinationFile,'w');
  
if args["to"] == "json":
  json.dump(Data, DF, indent=2);
elif args["to"] == "yaml":
  Y.dump(Data,DF);
# sys.stdout.flush();
else:
  print("Error: Incorrect --to parameter for conversion destination format!");
  exit(2);
```

### Пример работы скрипта:
```
20:45 root@chimaera /download/1 19:# > ./convertor.py --to yaml --source=hosts.yaml  --destination=test4.txt

20:45 root@chimaera /download/1 21:# > cat test3.txt 
[
  {
    "drive.google.com": "173.194.222.194"
  },
  {
    "mail.google.com": "64.233.163.18"
  },
  {
    "google.com": "108.177.14.113"
  }
]

20:55 root@chimaera /download/1 27:# > ./convertor.py --to yaml --source=hosts.yaml  
- {drive.google.com: 173.194.222.194}
- {mail.google.com: 64.233.163.18}
- {google.com: 108.177.14.113}

20:56 root@chimaera /download/1 28:# > ./convertor.py --to json --source=hosts.yaml  
[
  {
    "drive.google.com": "173.194.222.194"
  },
  {
    "mail.google.com": "64.233.163.18"
  },
  {
    "google.com": "108.177.14.113"
  }
]

20:57 root@chimaera /download/1 29:# > ./convertor.py --to json --source=hosts.json  
[
  {
    "drive.google.com": "173.194.222.194"
  },
  {
    "mail.google.com": "64.233.163.18"
  },
  {
    "google.com": "108.177.14.113"
  }
]

20:57 root@chimaera /download/1 30:# > ./convertor.py --to yaml --source=hosts.json  
- {drive.google.com: 173.194.222.194}
- {mail.google.com: 64.233.163.18}
- {google.com: 108.177.14.113}
```

----

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