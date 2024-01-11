# Ansible Collection - alex_pro.debian_clickhouse (для установки сервисов ClickHouse, LightHouse и Vector)

## Предназначение:

Коллекция ролей (clickhouse, vector и lighthouse) поднимает в Yandex Cloud COI сервисные контейнеры из готового универсального образа `debian_clickhouse`.

Playbook, который их вызывает сначала удаляет старые ранее созданные контейнеры для хостов из инвентарных групп `clickhouse`, `lighthouse` и `vector`, и потом создаёт и запускает их заново. В качестве хостов используются remote Docker контейнеры через `ansible_connection: docker` и SSH туннель до виртуальной машины в Yandex Cloud. 

## Запуск
Для запуска playbook нужно выполнить команду `./provision.sh`.

