# Дипломный практикум в Yandex.Cloud
# Автор решения - студент курса Netology DevOps27: Прокопьев Александр Борисович

---

## Файлы решения находятся в приватном `Git` репозитории под управлением установленного локально `Gitea`.

### Для проверки я предоставлю проверяющему по его запросу доступ, для чего мне необходимо будет временно включить туннель до public `endpoint` и прописать `IP` адрес проверяющего в файрволе этого `endpoint`.

Текст реферата (этого текстового описания) моего дипломного проекта предоставляется по лицензии AGPLv3, но некоторые файлы решения в приватном репозитории по другим видам лицензий.

---

### Установка и настройка локального Drone CI, интегрированного с Gitea

Для этого я написал гибко конфигурируемый `docker-compose.yml`, который позволяет задавать все важные параметры (около десятка параметров) установки связки `Gitea` + `Drone CI` в файле `.env`.

<details>
    <summary>: Исходный код файла .env ...  </summary>

```
#=== Gitea:
GITEA_HOST=gitea.<mydomain>.com 
# gitea

GITEA_DOMAIN=${GITEA_HOST}
GITEA_DOMAIN_TRAEFIK=gitea.<mydomain>.com
GITEA_IP=192.168.0.<xxx>
GITEA_INT_PORT=80
GITEA_EXT_PORT=80
GITEA_PORTS="${GITEA_IP}:${GITEA_EXT_PORT}:${GITEA_INT_PORT}"

#GITEA_VERSION=1.22.2
GITEA_VERSION=1.21.11

GITEA_ADMIN_USER=<xxx>

# unused#
ACME_EMAIL=acme@<mydomain>.com


LINODE_TOKEN=<xxx>

#=== Drone:
DRONE_HOST=drone
DRONE_DOMAIN_TRAEFIK=drone.<mydomain>.com
DRONE_DOMAIN=${DRONE_HOST}
DRONE_IP=192.168.0.<xxx>
DRONE_INT_PORT=80
DRONE_EXT_PORT=80
DRONE_PORTS="${DRONE_IP}:${DRONE_EXT_PORT}:${DRONE_INT_PORT}"

#DRONE_VERSION=2.4
DRONE_VERSION=2.24
DRONE_RUNNER_VERSION=1.8.3

DRONE_RPC_SECRET=<xxx>
DRONE_USER_CREATE="username:${GITEA_ADMIN_USER},machine:false,admin:true,token:${DRONE_RPC_SECRET}"

DRONE_GITEA_CLIENT_ID=<xxx>
DRONE_GITEA_CLIENT_SECRET=<xxx>

```

</details>

В такой конфигурации `Drone CI` интегрирован с `Gitea` и вход в `Drone CI` осуществляется через OAuth провайдер `Gitea`.

   
Кроме того сделал удобный скрипт запуска и перезапуска `docker-compose` в различных конфигурациях:
<details>
    <summary>: Исходный код файла restart.sh ...  </summary>

```
#!/bin/bash

Action=$1;

case $Action in
        ( all )
                StopProfiles=" --profile server --profile runner ";
                #Profiles=" --profile server ";
                StartProfiles=" --profile server --profile runner "; # for local runner
        ;;
        ( gitea )
                StopProfiles=" --profile gitea ";
                #Profiles=" --profile server ";
                StartProfiles=" --profile gitea ";
        ;;
esac;

./render_tpl.sh;

docker-compose $StopProfiles down;

/utils/docker/clean_stopped.sh;

docker-compose $StartProfiles up -d;

```

</details>

Скриншоты GUI `Gitea` и `Drone CI`:
![](images/gitea.png)
![](images/gitea_first_commit.png)
![](images/droneci.png)

### Создание и сборка тестового приложения

Сборка и деплой тестового приложения обеспечивается пайплайнами из файла `test-app/.drone.yml` (каталог `test-app` - это отдельный дополнительный `Git` репозиторий `alexpro/test-app`):
* `push` - сборка образа и сохранение его в `registry` с тэгом `:latest`
* `tag` - сборка приложения и сохранение его в `registry` с указанным тэгом.
* `promote` - установка приложения командой `kubectl apply -f`. Причём этот пайплайн работает только для повторного запуска после события `tag`, т.ё. только для тэгированных коммитом и соответственно потом успешно собрынных образов контейнеров.
* `rollback` - удаление приложения командой `kubectl delete -f`

В качестве `registry` для образов контейнеров собранного приложения я использовал отдельный `Gitea` репозиторий:
`alexpro/test-app-image`. Пока этот репозиторий находится локально, он доступен для managed кластера `K8s` через туннель, который включается кратковременно на время проверки.

### Создание облачной инфраструктуры (managed кластера Kubernetes)
В качестве кластера `K8s` я использую managed PaaS `K8s` в облаке `Yandex`.
Для начального развёртывания кластера `K8s` я написал модули `Terraform`, которые управляются моими модулями `Terragrunt` для удобства параметризации. 
Для запуска модулей `Terragrunt` я создал вспомогательный `Bash` скрипт `ctl.sh`, который в свою очередь вызывается из пайплайна `.drone.yml` по следующим `CI/CD` событиям:
* `push` - проверка плана `Terragrunt`
* `promote` - создание инфраструктуры командой `apply`, сразу же запускается и настройка кластера (установка и настройка дополнительного софта типа мониторинга)
* `rollback` - удаление инфраструктуры командой `destroy`

### Настройка кластера
Установка вспомогательных приложений (кроме тестового приложения) типа мониторинга  происходит на шаге `promote` пайплайна для создания кластера `K8s`.
`Grafana` с `Prometheus` ставится одним `helm` пакетом с небольшими модификациями `values.yml` для открытия их портов на соответствующих сервисах типа `NodePort`.

По завершении запуска модулей `Terragrant` и `Terraform` мой скрипт автоматически прописывает новые `K8s credentials` в конфиг `kubectl` и копирует их (токен и сертификат) в секреты `Drone CI` для
последующего  деплоя тестового приложения.

### Установка и настройка CI/CD для тестового приложения

* Деплой тестового приложения происходит с помощью повторного запуска пайплайна уже успешно собранного ранее билда тестового приложения, но с признаком `promote` в среду `prod`. Доступ к порту приложения обеспечивается тоже через `NodePort`.
* Удаление приложения происходит по `CI/CD` событию `rollback`.

---

### Для проверки я предоставлю проверяющему по его запросу доступ, для чего мне необходимо будет временно включить туннель до public `endpoint` и прописать `IP` адрес проверяющего в файрволе этого `endpoint`.

Текст реферата (этого текстового описания) моего дипломного проекта предоставляется по лицензии AGPLv3, но некоторые файлы решения в приватном репозитории по другим видам лицензий.

=========================== The Beginning of the Copyright Notice ===========================  
 The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev  
 born on December 20, 1977 resident of the city of Kurgan, Russia;  
 Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91  
 Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007  
 Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04  
 Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.  
 Contact of the AUTHOR: a.prokopyev.resume at gmail dot com  
 WWW: https://github.com/a-prokopyev-resume/devops-netology  
  
 All source code and other content contained in this file is protected by copyright law.  
 This file is licensed by the AUTHOR under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html  
  
 THIS FILE IS LICENSED ONLY PROVIDED FOLLOWING RESTRICTIONS ALSO APPLY:  
 Nobody except the AUTHOR may alter or remove this copyright notice from any copies of this file content (including modified fragments).  
 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an  
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   
  
 ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or   
 if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or licensee    
 is STRONGLY PROHIBITED to use this file by any method.  
============================== The End of the Copyright Notice ==============================  