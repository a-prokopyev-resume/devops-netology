
# [Домашнее задание](https://github.com/a-prokopyev-resume/virt-homeworks/tree/virt-11/05-virt-03-docker) к занятию 3. [«Введение. Экосистема. Архитектура. Жизненный цикл Docker-контейнера»](https://netology.ru/profile/program/virtd-27/lessons/274657/lesson_items/1471798)

Полезные линки:
[Описание DockerHub](https://itgap.ru/post/docker-hub-vvedenie).
[Рекомендации об удалении неиспользуемых облачных ресурсов](https://github.com/netology-code/virt-homeworks/blob/virt-11/r/README.md).

---

## Задача 1

Создал [task1/Dockerfile](src/task1/Dockerfile), который собирается с помощью Ansible плейбука [task1/build.yml](src/task1/build.yml), который запускается скриптом [task1/build.sh](src/task1/build.sh) 
(с использованием моего вспомогательного скрипта [/utils/iac/ansible.sh](https://github.com/a-prokopyev-resume/utils/iac/ansible.sh)) внутри другого инструментального контейнера, описанного в [предыдущей домашней работе](https://github.com/a-prokopyev-resume/devops-netology/tree/main/05-virt-02-iaac).
Ansible плейбук среди прочего также загружает собранный образ моего контейнера на dockerhub в мой репозиторий:
https://hub.docker.com/repository/docker/aprokopyev/devops-netology-05-virt-03-nginx/general

Запуск скрипта `task1/build.sh` приводит к следующему результату:
```
16:08 root@workstation /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task1 730:# > ./build.sh 
===> Executing command: docker exec  -ti  iac_tools_ansible ansible-playbook build.yml
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [localhost] ************************************************************************************************************************************************************************************************

TASK [Variables] ************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Build] ****************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Login] ****************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Push] *****************************************************************************************************************************************************************************************************
ok: [localhost]

PLAY RECAP ******************************************************************************************************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Теперь тестируем с помощью скрипта [task1/test.sh](src/task1/test.sh):
```
16:11 root@workstation /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task1 732:# > ./test.sh 
++ docker rmi aprokopyev/devops-netology-05-virt-03-nginx:v1 -f
Untagged: aprokopyev/devops-netology-05-virt-03-nginx:v1
Untagged: aprokopyev/devops-netology-05-virt-03-nginx@sha256:ff4feba28102731b2009d8affc4adef80fba9d630fd3370ae68ddffb1c15322a
Deleted: sha256:2b96da72a31632941048b8382ea30d547213168b2821d941df1190c68482312f
Deleted: sha256:c8c379ceafa36f66f03899a13eaccc75df41845029af1c2e8b8743a23fea8f0c
Deleted: sha256:31dee9759336f9aa4a7720a9d92cd339588168b568511a8ced451c41cd15f37f
++ docker run -p 8080:80 --detach --name 05-virt-03-nginx aprokopyev/devops-netology-05-virt-03-nginx:v1
Unable to find image 'aprokopyev/devops-netology-05-virt-03-nginx:v1' locally
v1: Pulling from aprokopyev/devops-netology-05-virt-03-nginx
7264a8db6415: Already exists 
518c62654cf0: Already exists 
d8c801465ddf: Already exists 
ac28ec6b1e86: Already exists 
eb8fb38efa48: Already exists 
e92e38a9a0eb: Already exists 
58663ac43ae7: Already exists 
2f545e207252: Already exists 
f9a83f261845: Pull complete 
10f56e403c47: Pull complete 
Digest: sha256:ff4feba28102731b2009d8affc4adef80fba9d630fd3370ae68ddffb1c15322a
Status: Downloaded newer image for aprokopyev/devops-netology-05-virt-03-nginx:v1
1eccd42cdcb06f12748e6d7b8cd36bc3541d21532cfd9271bec155f0fc6b6157
++ sleep 3s
++ curl localhost:8080
++ cat
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   108  100   108    0     0   5627      0 --:--:-- --:--:-- --:--:--  6000
<html>
  <head>
    Hey, Netology
  </head>
  <body>
    <h1>I’m DevOps Engineer!</h1>
    </body>
</html>++ docker stop 05-virt-03-nginx
05-virt-03-nginx
++ /utils/docker/clean_stopped.sh
Deleted Containers:
1eccd42cdcb06f12748e6d7b8cd36bc3541d21532cfd9271bec155f0fc6b6157

Total reclaimed space: 0B
```

Видим, что `curl localhost:8080` показывает страницу из запущенного контейнера.

## Задача 2

- Высоконагруженное монолитное Java веб-приложение.  
Хорошо масштабируемая вертикально физическая или виртуальная машина.  
- Nodejs веб-приложение.  
Контейнеры, особенно, если приложение способно работать в нескольких репликах.
- Мобильное приложение c версиями для Android и iOS.  
Front ends устанавливаются на физические мобильные устройства, иногда при тестировании на виртуальные машины - эмуляторы устройств.
Back end обычно разрабатывается для запуска в контейнерах в т.ч. в кластере.
- Шина данных на базе Apache Kafka  
В контейнерах и/или паравиртуальных машинах.
- Elasticsearch-кластер для реализации логирования продуктивного веб-приложения — три ноды elasticsearch, два logstash и две ноды kibana.  
В контейнерах. 
- Мониторинг-стек на базе Prometheus и Grafana.  
В контейнерах.
- MongoDB как основное хранилище данных для Java-приложения.  
На физических хостах или в виртуалках или в контейнерах. Зависит от нагрузки, SLA, необходимости наличия кластера и т.п.
- Gitlab-сервер для реализации CI/CD-процессов и приватный (закрытый) Docker Registry.
Я обычно стараюсь размещать почти все в контейнерах, работающих в виртуалках, кроме тех случаев, когда такое размещение не подходит по причинам производительности (ухудшению показателей latency и т.п.) либо потенциальном риске нарушения SLA,
например, для высоконагруженного HA кластера реляционной ACID СУБД с очень строгим SLA. 

## Задача 3

Задача решается моим скриптом [task3/test.sh](src/task3/test.sh)  
Он запускает два нужных контейнера и потом запускает скрипты [task3/c1.sh](src/task3/c1.sh) и [task3/c2.sh](src/task3/c2.sh) в соответствующих контейнерах.
Причем сообщение с хоста в скрипт `c1.sh`, запускаемого внутри контейнера C1, передается через shell pipe 
(c помощью вызовов функций из моей библиотеки [/utils/docker/lib.sh](https://github.com/a-prokopyev-resume/utils/docker/lib.sh) БЕЗ использования `--volume` файлов в качестве среды IPC, а в `c2.sh` через `data/message_for_c2.txt` в `--volume` /data. 
Кроме того делается очистка от ранее запущенных контейнеров в начале и в конце этого скрипта.

```
15:42 root@workstation /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3 70:# > ./test.sh 
++ Container1ImageName=centos
++ Container1Name=C1
++ Container2ImageName=debian
++ Container2Name=C2
+++ realpath data
++ RealDataPath=/xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data
++ clean_all
++ docker stop C1 C2
Error response from daemon: No such container: C1
Error response from daemon: No such container: C2
++ /utils/docker/clean_stopped.sh
Total reclaimed space: 0B
++ docker_run centos C1 bash -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data:/data
++ ContainerImageName=centos
++ ContainerName=C1
++ RunCmd=bash
++ MoreDockerOptions='-v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data:/data'
+++ pwd
++ DockerRunCmd='docker run -dti -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3:/workspace -v /utils:/utils -w /workspace --user root --name C1 -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data:/data centos bash'
++ Result=0
++ docker run -dti -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3:/workspace -v /utils:/utils -w /workspace --user root --name C1 -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data:/data centos bash
768388b3a3747939c73a4e5c50435c24e0c89dd6d980cfa943ca6e799e0c3074
++ Result=0
++ return 0
++ docker_run debian C2 bash -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data:/data
++ ContainerImageName=debian
++ ContainerName=C2
++ RunCmd=bash
++ MoreDockerOptions='-v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data:/data'
+++ pwd
++ DockerRunCmd='docker run -dti -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3:/workspace -v /utils:/utils -w /workspace --user root --name C2 -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data:/data debian bash'
++ Result=0
++ docker run -dti -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3:/workspace -v /utils:/utils -w /workspace --user root --name C2 -v /xxx/Netology/DevOps27/Homework/05-virt-03-docker/src/task3/data:/data debian bash
61d1c3974e62b4c1bd23d271c5b725f08e98e484981c0e1acb4af0420443d901
++ Result=0
++ return 0
++ touch data/c1_reply.txt
++ echo 'Hello from host to C1 via shell pipe!'
++ docker_exec C1 bash -lc /workspace/c1.sh
++ ContainerName=C1
++ ExecArgs='bash -lc /workspace/c1.sh'
+++ timeout 0.1s ifne cat
++ InText='Hello from host to C1 via shell pipe!'
++ '[' -n 'Hello from host to C1 via shell pipe!' ']'
++ Options=' -i '
++ DockerExecCmd='docker exec  -i  C1 bash -lc /workspace/c1.sh'
++ echo '===> Executing command: docker exec  -i  C1 bash -lc /workspace/c1.sh'
===> Executing command: docker exec  -i  C1 bash -lc /workspace/c1.sh
++ Result=0
++ '[' -n 'Hello from host to C1 via shell pipe!' ']'
++ echo -n Hello from host to C1 via shell 'pipe!'
++ docker exec -i C1 bash -lc /workspace/c1.sh
===> This is a reply from container C1
The host has sent message: Hello from host to C1 via shell pipe!
++ Result=0
++ return 0
++ echo 'Hello from host to C2 via /data volume!'
++ docker_exec C2 bash -lc /workspace/c2.sh
++ ContainerName=C2
++ ExecArgs='bash -lc /workspace/c2.sh'
+++ timeout 0.1s ifne cat
++ InText=
++ '[' -n '' ']'
++ Options=' -ti '
++ DockerExecCmd='docker exec  -ti  C2 bash -lc /workspace/c2.sh'
++ echo '===> Executing command: docker exec  -ti  C2 bash -lc /workspace/c2.sh'
===> Executing command: docker exec  -ti  C2 bash -lc /workspace/c2.sh
++ Result=0
++ '[' -n '' ']'
++ docker exec -ti C2 bash -lc /workspace/c2.sh
++ ls -alh /data
total 10K
drwxr-xr-x  2 root root   4 Sep 15 10:37 .
drwxr-xr-x 20 root root   5 Sep 15 10:42 ..
-rw-r--r--  1 root root 104 Sep 15 10:42 c1_reply.txt
-rw-r--r--  1 root root  40 Sep 15 10:42 message_for_c2.txt
++ cat /data/c1_reply.txt /data/message_for_c2.txt
===> This is a reply from container C1
The host has sent message: Hello from host to C1 via shell pipe!
Hello from host to C2 via /data volume!
++ Result=0
++ return 0
++ clean_all
++ docker stop C1 C2
C1
C2
++ /utils/docker/clean_stopped.sh
Deleted Containers:
61d1c3974e62b4c1bd23d271c5b725f08e98e484981c0e1acb4af0420443d901
768388b3a3747939c73a4e5c50435c24e0c89dd6d980cfa943ca6e799e0c3074

Total reclaimed space: 0B
```

## Задача 4 (*)

Задача 1 из этой домашней работы решена как раз в т.ч. с помощью Ansible.