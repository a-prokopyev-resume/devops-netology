# === ПОКА НЕ ГОТОВО ДЛЯ ПРОВЕРКИ === 

# Домашнее задание к занятию 15 «Система сбора логов Elastic Stack»

# Зачёт по модулю в целом я уже получил (достаточно трёх работ), но хотелось бы сдать и эту работу.

# Пожалуйста, пока не берите эту работу на проверку или если уже взяли, то пусть, она пока повисит в непроверенном состоянии или можете взять на проверку другую работу, НЕ СТАВЯ НЕЗАЧЁТ у этой, тогда эта работа автоматически снимется с проверки или окажется в списке взятых на проверку, но ещё не проверенных в зависимости от настройки LMS для учётки соответствующего проверяющего.

# === ПОКА НЕ ГОТОВО ДЛЯ ПРОВЕРКИ === 


## Дополнительные ссылки

Прочитал документацию по предложенным в занятии ссылкам и ещё по этому линку: https://github.com/codingexplained/complete-guide-to-elasticsearch

## Задание 1
Поискал на Github популярные готовые проекты на базе docker-compose на тему занятия и нашёл такие проекты:

* https://github.com/sherifabdlnaby/elastdocker
* https://github.com/deviantony/docker-elk
* https://github.com/spujadas/elk-docker

Больше всего мне понравился первый из них (Elastdocker), потому что этот вариант подходит для промышленного использования (возможно с минимальными доработками), в нём есть следующие полезные features:

### Main Features of Elastdocker:
- Configured as a Production Single Node Cluster. (With a multi-node cluster option for experimenting).
- Security Enabled By Default.
- Configured to Enable:
  - Logging & Metrics Ingestion
    - Option to collect logs of all Docker Containers running on the host. via `make collect-docker-logs`.
  - APM
  - Alerting
  - Machine Learning
  - Anomaly Detection
  - SIEM (Security information and event management).
  - Enabling Trial License
- Use Docker-Compose and `.env` to configure your entire stack parameters.
- Persist Elasticsearch's Keystore and SSL Certifications.
- Self-Monitoring Metrics Enabled.
- Prometheus Exporters for Stack Metrics.
- Embedded Container Healthchecks for Stack Images.

Виртуальную машину быстро развернул развернул в YC с помощью своего универсального модуля Terraform.

Сейчас устанавливаю Elastdocker, но репозиторий Elasticsearch заблокирован в РФ, а через прокси контейнеры загружаются очень медленно.

