# [Домашнее задание](https://github.com/a-prokopyev-resume/virt-homeworks/tree/virt-11/05-virt-02-iaac) к занятию 2. [«Применение принципов IaaC в работе с виртуальными машинами»](https://netology.ru/profile/program/virtd-27/lessons/274656/lesson_items/1471789)

## Задача 1

- Основные преимущества применения на практике IaaC-паттернов:
  - Простота создания виртуальной инфраструктуры 
  - Гармоничное развитие модели "Инфраструктура как сервис"
  - Автоматизируемость при повторном развертывании с тем же результатом (aka индемпотентность). Особенно полезно при срочном восстановлении в аварийной ситуации.
  - Уменьшение количества времени, затрачиваемого на рутинные операции как при создании IaC, так и при эксплуатации. 
  - Возможность версионирования в централизованном VCS позволяет лучше документировать, регистрировать и отслеживать каждое изменение конфигурации вашего сервера.
  - Возможность совместной разработки IaC одновременно несколькими исполнителями, удобство code review.
  - Возможность тестирования IaC, в т.ч. автоматизированное.
  - Уменьшение рисков при работе с инфраструктурой. 

Принципы IaC позволяют не фокусироваться на рутине, а заниматься более важными задачами. 
Автоматизация инфраструктуры позволяет эффективнее использовать существующие ресурсы. 
Также автоматизация позволяет минимизировать риск возникновения человеческой ошибки. 
Всё это является частью культуры DevOps, сочетающей в себе разработку и операции.

**Основополагающий принцип IaC - это идемпотентность создаваемой конфигурации.** 

## Задача 2

- Преимущества Ansible по сравнению с другими системами управления конфигурациями
  - Довольно легкая система с точки зрения потребления ресурсов, минимализм в архитектуре. Не создает дополнительных зависимостей при использовании.
  - Дополнительно к push режиму по умолчанию, способен работать так же и в pull режиме, но тогда нужно устанавливать Ansible на управляемые хосты.
  - Безопасен за счет использования open-ssh.
  - Надежен и обычно идемпотентен.
  - Удобный синтаксис YAML and Jinja.
  - Большое количество готовых ролей в библиотеке Ansible Galaxy.
  - Хорошее оповещение о проблемах, обнаруженных при запуске плейбука.
  - Низкий порог входа для новых специалистов.
  - Большое количество специалистов на рынке труда.


- Надежность инструмента с точки зрения способа доставки изменений (push vs pull).
  - К преимуществам push в случае с Ansible можно отнести легкую и удобную организацию версионирования Ansible скриптов в репозитории Git.
  - При использовании push метода управляющий скрипт исполняется на управляющем хосте, а НЕ на каждом управляемом хосте, что с одной стороны может быть удобно для отладки, 
а с другой несколько замедляет работу в случае большого количества управляемых хостов, что можно уже отнести к недостаткам метода push. Однако Ansible поддерживает параллельный provisioning.
  - Возможно при использовании push так же легче выбирать момент применения изменений, и можно уменьшить объем трафика, который расходуется на периодичные повторяемые запросы pull, 
и избежать лишних сообщений системы об ошибках, если было окно обслуживания сетевой инфры, во время которого сеть недоступна.
  - Если под надежностью понимать в т.ч. и безопасность, то IMHO безопаснее использование SSH с неизвлекаемыми ключами в аппаратном крипто (PKCS11 и U2F).
В принципе через SSH можно туннелировать любые другие протоколы (как в режиме push, так и pull), 
даже L2 при использовании дополнительного вложенного туннеля типа OpenVPN TAP в режиме TCP 
(хоть это и неэффективно с точки зрения скорости работы, зато в итоге через SSH).
Ansible удобен тем, что использует open-ssh уже сразу по умолчанию самостоятельно.


## Задача 3

Вместо VirtualBox я использую виртуалки QEMU+KVM и LXC контейнеры:
```
20:00 root@kube ~ 13:# > vagrant plugin list
qemu (1.0, global)
vagrant-host-shell (0.0.4, global)
vagrant-libvirt (0.12.2, global)
vagrant-linode (0.4.1, global)
vagrant-lxc (1.4.3, global)
vagrant-lxd (0.6.0, global)
vagrant-managed-servers (0.8.0, global)

20:01 root@kube ~ 14:# > dpkg -al | grep lxc
ii  liblxc1:amd64                        1:4.0.6-2+deb11u2                  amd64        Linux Containers userspace tools (library)
ii  libvirt-daemon-driver-lxc            8.0.0-1~bpo11+1                    amd64        Virtualization daemon LXC connection driver
ii  lxc                                  1:4.0.6-2+deb11u2                  amd64        Linux Containers userspace tools
ii  lxc-templates                        3.0.4-5                            amd64        Linux Containers userspace tools (templates)
ii  lxcfs                                4.0.7-1                            amd64        FUSE based filesystem for LXC

20:09 root@workstation /download 1:# > dpkg -al | grep qemu
ii  aqemu                                                       0.9.2-2+b1                                               amd64        Qt5 front-end for QEMU and KVM
ii  ipxe-qemu                                                   1.0.0+git-20161027.b991c67-1                             all          PXE boot firmware - ROM images for qemu
ii  qemu                                                        1:2.8+dfsg-6+deb9u18                                     amd64        fast processor emulator
ii  qemu-kvm                                                    1:2.8+dfsg-6+deb9u18                                     amd64        QEMU Full virtualization on x86 hardware
hi  qemu-slof                                                   20161019+dfsg-1                                          all          Slimline Open Firmware -- QEMU PowerPC version
ii  qemu-system                                                 1:2.8+dfsg-6+deb9u18                                     amd64        QEMU full system emulation binaries
ii  qemu-system-arm                                             1:2.8+dfsg-6+deb9u18                                     amd64        QEMU full system emulation binaries (arm)
ii  qemu-system-common                                          1:2.8+dfsg-6+deb9u18                                     amd64        QEMU full system emulation binaries (common files)
ii  qemu-system-mips                                            1:2.8+dfsg-6+deb9u18                                     amd64        QEMU full system emulation binaries (mips)
ii  qemu-system-misc                                            1:2.8+dfsg-6+deb9u18                                     amd64        QEMU full system emulation binaries (miscellaneous)
ii  qemu-system-ppc                                             1:2.8+dfsg-6+deb9u18                                     amd64        QEMU full system emulation binaries (ppc)
ii  qemu-system-sparc                                           1:2.8+dfsg-6+deb9u18                                     amd64        QEMU full system emulation binaries (sparc)
ii  qemu-system-x86                                             1:2.8+dfsg-6+deb9u18                                     amd64        QEMU full system emulation binaries (x86)
ii  qemu-user                                                   1:2.8+dfsg-6+deb9u18                                     amd64        QEMU user mode emulation binaries
ii  qemu-user-static                                            1:2.8+dfsg-6+deb9u18                                     amd64        QEMU user mode emulation binaries (static version)
ii  qemu-utils                                                  1:2.8+dfsg-6+deb9u18                                     amd64        QEMU utilities
```

Версии установленных инструментов для IaC:
```
19:59 root@kube ~ 9:# > ansible --version
ansible 2.10.8
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.9.2 (default, Feb 28 2021, 17:03:44) [GCC 10.2.1 20210110]

19:59 root@kube ~ 10:# > vagrant version
Installed Version: 2.3.4


20:15 root@kube /etc/apt/sources.list.d 28:# > cat terraform.list
deb [arch=amd64] https://apt.releases.hashicorp.com bullseye main

20:14 root@kube /etc/apt/sources.list.d 27:# > terraform -v
Terraform v1.5.7
on linux_amd64
```

Хотелось бы в дальнейшем использовать контейнеры для установки подобных инструментов, в данном случае следующие контейнеры:
```
14:31 root@workstation /download 5:# > docker images
REPOSITORY                                      TAG            IMAGE ID       CREATED          SIZE                                                                                                                                  
devopsinfra/docker-terragrunt                   latest         018ffd2dafb1   28 minutes ago   1.18GB
devopsinfra/docker-terragrunt-ansible-joe       latest         25944a9b3bcd   40 hours ago   1.77GB 
vagrantlibvirt/vagrant-libvirt                  latest         f6581b1aab61   2 months ago     504MB  
```
`devopsinfra/docker-terragrunt-ansible-joe` - это переделанный мной `devopsinfra/docker-terragrunt` добавлением в него `ansible` и некоторых других полезных утилит.  
Эти контейнеры позволяют работать с Terraform (и Terragrunt wrapper), Ansible, Libvirt и LXD (на внешних remote хостах) через Vagrant:
https://hub.docker.com/r/vagrantlibvirt/vagrant-libvirt
Кроме того я использую свой скрипт для удобного запуска подобных инструментальных контейнеров:
https://github.com/a-prokopyev-resume/utils/blob/main/docker/lib.sh
Возможно это (вызовы такого скрипта из другого скрипта Bash) чем-то походит на очень примитивный CI/CD pipeline. 

Пока к сожалению остаются вопросы, как правильно настроить сеть виртуалок через libvirt снаружи таких
контейнеров, т.е. управление демоном libvirt через сокет, проброшенный через
docker volumes у меня работает нормально, но впечатление, что бриджи создаваемые
демоном libvirt остаются недоконфигурированными и vagrant внутри контейнера
не может подключиться через них. В netstat видно строку с состоянием SYN для
ssh. Поэтому, пока такой способ у меня не работает, я также установил Vagrant и Ansible на одном из своих виртуальных хостов:
```
13:22 root@kube ~ 1:# > vagrant version
Installed Version: 2.3.4

13:22 root@kube ~ 2:# > ansible --version
ansible 2.10.8
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.9.2 (default, Feb 28 2021, 17:03:44) [GCC 10.2.1 20210110]
```

Пока для меня актуальны следующие вопросы по этой задаче:

* Можно ли управлять из Vagrant на первом хосте гипервизором, расположенным на втором хосте, без установки Vagrant на второй хост?
Хотелось бы запускать Vagrant внутри Docker контейнера, на хостах, где затруднительно установить актуальную версию Vagrant из репозитория, а при установке через AppImage появляются глюки с работой плагинов и т.п. Т.е. нужно сделать так, чтобы на хосте, где непосредственно происходит виртуализация не было установлено Vagrant, но чтобы была возможность рулить таким хостом из контейнера(с Vagrant внутри контейнера).
Vagrant in Docker -> сеть или /run/xxx/socket -> удаленно управляемый типа libvirt или LXD виртуализатор.

* Пытался проделать такой фокус с виртуализатором libvirt KVM пока только через управляющий socket, проброшенный через --volume. Удалось создать виртуальную машину, но пока проблемы при конфигурировании сети.

* Какие еще поддерживаемые в Vagrant (хотя бы плагинами) виртуализаторы управляемы из Vagrant удаленно по сети или хотя бы через /run/xxx/socket? Собираюсь попробовать плагин LXD, но в нем опять нет штатной возможности определить private_network со статическим IP адресом. VirtualBox такое умеет?

* Пример подобного решения для libvirt: https://hub.docker.com/r/vagrantlibvirt/vagrant-libvirt


## Задача 4 

Я использовал Vagrant провайдер libvirt внутри контейнера через `/run/libvirt/virtlogd-sock`, пытаясь управлять виртуалкой на том же хосте, где запущен докер. 
Для этого пришлось немного переделать оригинальный Vagrantfile, предложенный на лекции.
Пока есть некоторые проблемы с настройкой сети, эта задача немного недоделана из-за проблем, подробнее описанных в предыдущей задаче 3 этой же домашней работы.
