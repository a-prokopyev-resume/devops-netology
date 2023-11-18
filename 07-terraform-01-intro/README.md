# [Домашнее задание](https://github.com/netology-code/virt-homeworks/tree/virt-11/07-terraform-01-intro) к занятию [1. «Инфраструктура как код»](https://netology.ru/profile/program/ter-27/lessons/284423/lesson_items/1529735)

## Задача 1. Выбор инструментов

1. В случае повышенных требований к безопасности я бы использовал неизменяемую архитектуру, а иначе можно и изменяемую.
2. Современные инструменты типа Terraform и Ansible не требуют центрального сервера кроме возможного использования различных репозиториев в т.ч. локальных при желании.
3. Агенты на серверах ненужны.
4. Для инициализации серверов будет использоваться Ansible.

Я бы оставил следующие современные инструменты: Packer, Terraform, Docker, Kubernetes. 
Teamcity с моей точки зрения слишком экзотичный, я бы заменил его на более популярный open-source CD/CD инструмент типа GitLab.
Кроме того локально на своём хосте я бы использовал более универсальный Drone CI с плагином GitLab.
Часть bash скриптов я бы попытался заменить на Ansible скрипты, некоторые предложил бы переписать на C# с компиляцией в [бинарный AOT executable без привязки к runtime аналогично](https://www.opennet.ru/opennews/art.shtml?num=60112) Golang, остальные bash скрипты пришлось бы оставить.

![](https://devblogs.microsoft.com/dotnet/wp-content/uploads/sites/10/2023/11/AOTOptimizations3.png)

## Задача 2. Установка Terraform
Я написал Dockerfile, который создает образ контейнера с Terraform, Terragrunt и другими инструментами для работы над IaC:

```
ARG Arch
ARG Release

FROM $Arch/debian_base:$Release

ARG DEBIAN_FRONTEND
ARG AptOptions
RUN echo $DEBIAN_FRONTEND $AptOptions

RUN apt update $AptOptions && apt install $AptOptions --allow-downgrades libc6=2.36-9+deb12u2 && apt install $AptOptions --allow-downgrades libc6-dev=2.36-9+deb12u2

RUN proxychains wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
        gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint && \
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
        proxychains apt $AptOptions update && proxychains apt $AptOptions install terraform;

RUN apt install $AptOptions \
        libvirt-clients \
        qemu-utils \
        ruby-libvirt \
        libxslt-dev \
        libxml2-dev \
        libvirt-dev \
        ruby-bundler \
        ruby-dev \
        zlib1g-dev \
        docker-compose docker.io \
        mariadb-backup mariadb-client mariadb-common libmariadb-dev && \
        apt purge $AptOptions docker-compose && \
        ( apt install $AptOptions mariadb-client-10.5 mariadb-client-core-10.5 || apt install $AptOptions mariadb-client-core );

RUN pip3 install --break-system-packages ansible docker-py 

ADD files/docker-compose /sbin/docker-compose
ADD files/terragrunt /sbin/terragrunt
```

Сборка работает в т.ч. и в РФ, потому что используется зарубежный прокси через проксификатор `proxychains`.

Проверяем версии:
```
root@debian_iac:/# terraform --version
Terraform v1.6.4
on linux_amd64

root@debian_iac:/# terragrunt --version
terragrunt version v0.53.4
```

## Задача 3. Поддержка legacy-кода
Я бы создал ещё один образ контейнера с другой версией Terraform:
```
root@debian_iac:/# apt list -a terraform

Listing... Done
terraform/bookworm,now 1.6.4-1 amd64 [installed]
terraform/bookworm 1.6.3-1 amd64
terraform/bookworm 1.6.2-1 amd64
terraform/bookworm 1.6.1-1 amd64
terraform/bookworm 1.6.0-1 amd64
terraform/bookworm 1.5.7-1 amd64
terraform/bookworm 1.5.6-1 amd64
terraform/bookworm 1.5.5-1 amd64
terraform/bookworm 1.5.4-1 amd64
terraform/bookworm 1.5.3-1 amd64
terraform/bookworm 1.5.2-1 amd64
terraform/bookworm 1.5.1-1 amd64
terraform/bookworm 1.5.0-1 amd64
terraform/bookworm 1.4.7-1 amd64
terraform/bookworm 1.4.6-1 amd64
terraform/bookworm 1.4.5-1 amd64
terraform/bookworm 1.4.4-1 amd64
terraform/bookworm 1.4.3-1 amd64
terraform/bookworm 1.4.2 amd64
terraform/bookworm 1.4.1 amd64
terraform/bookworm 1.4.0 amd64
terraform/bookworm 1.3.10-1 amd64
terraform/bookworm 1.3.9 amd64
terraform/bookworm 1.3.8 amd64
terraform/bookworm 1.3.7 amd64
terraform/bookworm 1.3.6 amd64
terraform/bookworm 1.3.5 amd64
terraform/bookworm 1.3.4 amd64
terraform/bookworm 1.3.3 amd64
terraform/bookworm 1.3.2 amd64
terraform/bookworm 1.3.1 amd64
terraform/bookworm 1.3.0 amd64
terraform/bookworm 1.2.9 amd64
terraform/bookworm 1.2.8 amd64
terraform/bookworm 1.2.7 amd64
terraform/bookworm 1.2.6 amd64
terraform/bookworm 1.2.5 amd64
terraform/bookworm 1.2.4 amd64
terraform/bookworm 1.2.3 amd64
terraform/bookworm 1.2.2 amd64
terraform/bookworm 1.2.1 amd64
terraform/bookworm 1.2.0 amd64
terraform/bookworm 1.1.9 amd64
terraform/bookworm 1.1.8 amd64
terraform/bookworm 1.1.7 amd64
terraform/bookworm 1.1.6 amd64
terraform/bookworm 1.1.5 amd64
terraform/bookworm 1.1.4 amd64
terraform/bookworm 1.1.3 amd64
terraform/bookworm 1.1.2 amd64
terraform/bookworm 1.1.1 amd64
terraform/bookworm 1.1.0 amd64
terraform/bookworm 1.0.11 amd64
terraform/bookworm 1.0.10 amd64
terraform/bookworm 1.0.9 amd64
terraform/bookworm 1.0.8 amd64
terraform/bookworm 1.0.7 amd64
terraform/bookworm 1.0.6 amd64
terraform/bookworm 1.0.5 amd64
terraform/bookworm 1.0.4 amd64
terraform/bookworm 1.0.3 amd64
terraform/bookworm 1.0.2 amd64
terraform/bookworm 1.0.1 amd64
terraform/bookworm 1.0.0 amd64
terraform/bookworm 0.15.5 amd64
terraform/bookworm 0.15.4 amd64
terraform/bookworm 0.15.3 amd64
terraform/bookworm 0.15.2 amd64
terraform/bookworm 0.15.1 amd64
terraform/bookworm 0.15.0 amd64
terraform/bookworm 0.14.11 amd64
terraform/bookworm 0.14.10 amd64
terraform/bookworm 0.14.9 amd64
terraform/bookworm 0.14.8 amd64
terraform/bookworm 0.14.7 amd64
terraform/bookworm 0.14.6 amd64
terraform/bookworm 0.14.5 amd64
terraform/bookworm 0.14.4 amd64
terraform/bookworm 0.14.3 amd64
terraform/bookworm 0.14.2 amd64
terraform/bookworm 0.14.1 amd64
terraform/bookworm 0.14.0 amd64
terraform/bookworm 0.13.7 amd64
terraform/bookworm 0.13.6 amd64
terraform/bookworm 0.13.5 amd64
terraform/bookworm 0.13.4-2 amd64
terraform/bookworm 0.13.4 amd64
terraform/bookworm 0.13.3-2 amd64
terraform/bookworm 0.13.3 amd64
terraform/bookworm 0.13.2 amd64
terraform/bookworm 0.13.1 amd64
terraform/bookworm 0.13.0 amd64
terraform/bookworm 0.12.31 amd64
terraform/bookworm 0.12.30 amd64
terraform/bookworm 0.12.29 amd64
terraform/bookworm 0.12.28 amd64
terraform/bookworm 0.12.27 amd64
terraform/bookworm 0.12.26 amd64
terraform/bookworm 0.11.15 amd64
terraform/bookworm 0.11.14 amd64
```