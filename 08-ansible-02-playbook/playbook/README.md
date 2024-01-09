# Playbook для установки сервисов ClickHouse и Vector

## Предназначение:

Playbook делает следующее:  
- Создаёт образ контейнера debian_clickhouse, который включает в себя:
    -  следующие пакеты из репозитория ClickHouse:
        * сlickhouse-client
        * clickhouse-server
        * clickhouse-common
  -  следующие пакеты из репозитория Vector:
       * vector

 Playbook `debian_template.yml` проверяет наличие локального образа `debian_clickhouse`, и в случае его отсутствия автоматически добавляет соответствующие репозитории Clickhouse и Vector к образу python3 на базе дистрибутива Debian, а потом устанавливает следующие пакеты:
  - сlickhouse-client
  - clickhouse-server
  - clickhouse-common
  - vector
  
Кроме того playbook добавляет в образ [лайтовый контейнерный мод systemd](https://github.com/gdraheim/docker-systemctl-replacement) для управления установленными сервисами и создает config файл для сервиса Vector по шаблону. 

Playbook `on_start.yml` удаляет старые ранее созданные контейнеры для хостов из инвентарных групп `clickhouse` и `vector`, и потом создаёт и запускает их заново. В качестве хостов используются локальные Docker контейнеры через `ansible_connection: docker`. 

Playbook `site.yml` сначала запускает `on_start.yml` для пересоздания нужных виртуальных хостов в контейнерах, а потом включает и запускает соответствующие сервисы.

## Параметры
- Имена хостов, представленных Docker контейнерами, указываются в `inventory/prod.yml`.
- Устанавливаемые пакеты указываются в файлах переменных типа `vars/main.yml`.

## Запуск
Для запуска playbook нужно выполнить команду `./site.sh`, которая содержит следующий скрипт:
```
ansible-playbook -e @vars/main.yml  site.yml -i inventory/prod.yml;
```
Почему-то приходится явно указывать опцией `-e @vars/main.yml` файл переменных, иначе не работает (не находит соответствующие переменные).
