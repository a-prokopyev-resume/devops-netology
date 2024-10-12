# Дипломный практикум в Yandex.Cloud
# Автор решения - студент курса Netology DevOps27: Прокопьев Александр Борисович

---

## Файлы решения находятся в приватном `Git` репозитории под управлением установленного локально `Gitea`.

### Для проверки я предоставлю проверяющему по его запросу доступ, для чего мне необходимо будет временно включить туннель до public `endpoint` и прописать `IP` адрес проверяющего в файрволе этого `endpoint`.

Текст реферата (этого текстового описания) моего дипломного проекта предоставляется по лицензии AGPLv3, но некоторые файлы решения в приватном репозитории по другим видам лицензий.

---

### Установка и настройка локального Drone CI, интегрированного с Gitea

Для этого я написал гибко конфигурируемый `docker-compose`, который позволяет задавать все важные параметры (около десятка параметров) установки связки `Gitea` + `Drone CI` в файле `.env`.
Кроме того сделал удобный скрипт запуска и перезапуска `docker-compose` в различных конфигурациях.

### Создание и сборка тестового приложения

Сборка и деплой тестового приложения обеспечивается пайплайнами из файла `test-app/.drone.yml` (test-app - это отдельный репозиторий `alexpro/test-app`):
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