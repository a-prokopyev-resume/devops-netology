# [Домашнее задание](https://github.com/a-prokopyev-resume/sysadm-homeworks/tree/devsys10/03-sysadmin-07-net) к занятию [«Компьютерные сети. Лекция 2»](https://netology.ru/profile/program/sys-dev-27/lessons/242282/lesson_items/1286609)

### Цель задания

В результате выполнения задания вы:

* познакомитесь с инструментами настройки сети в Linux, агрегации нескольких сетевых интерфейсов, отладки их работы;
* примените знания о сетевых адресах на практике для проектирования сети.

------

## Решения задач

1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?

Ответ:  
Linux: `ifconfig -a; ip l`  
Windows: `ipconfig /all`  

Пример использования:
```
root@workstation ~ 19:# > ifconfig -a
ethX: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.123  netmask 255.255.255.0  broadcast 192.168.0.255
        ether 1c:f0:49:6a:40:d1  txqueuelen 1000  (Ethernet)
        RX packets 3378737  bytes 3326588238 (3.0 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2568428  bytes 508598961 (485.0 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ethX:1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.124  netmask 255.255.255.0  broadcast 192.168.1.255
        ether 1c:f0:49:6a:40:d1  txqueuelen 1000  (Ethernet)

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 4329446  bytes 4101430290 (3.8 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4329446  bytes 4101430290 (3.8 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@workstation ~ 20:# > ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 1c:f0:49:6a:40:d1 brd ff:ff:ff:ff:ff:ff
```

2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?

Ответ: Для этого используется протокол LLDP, который поддерживает софт из пакета lldpd, в котором среди прочего есть нужная нам команда lldpctl.

Пример использования:
```
root@kube ~ 2:# > lldpctl 
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
Interface:    vethWEIQ4p, via: LLDP, RID: 1, Time: 0 day, 00:01:12
  Chassis:     
    ChassisID:    mac da:a8:d7:c4:b2:e1
    SysName:      focal-base
    SysDescr:     Ubuntu 20.04.5 LTS Linux 5.15.24-gnu #1.0 SMP Tue Sep 27 12:35:59 EST 1983 x86_64
    MgmtIP:       10.0.3.186
    MgmtIface:    2
    Capability:   Bridge, on
    Capability:   Router, on
    Capability:   Wlan, off
    Capability:   Station, off
  Port:        
    PortID:       mac da:a8:d7:c4:b2:e1
    PortDescr:    eth0
    TTL:          120
    PMD autoneg:  supported: no, enabled: no
      MAU oper type: 10GigBaseCX4 - X copper over 8 pair 100-Ohm balanced cable
-------------------------------------------------------------------------------

root@focal-base:/home/vagrant# lldpctl 
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
Interface:    eth0, via: LLDP, RID: 1, Time: 0 day, 00:01:00
  Chassis:     
    ChassisID:    mac f2:3c:92:fc:9b:e9
    SysName:      kube
    SysDescr:     Devuan GNU/Linux 4 (chimaera) Linux 5.15.24-gnu #1.0 SMP Tue Sep 27 12:35:59 EST 1983 x86_64
    MgmtIP:       xx.155.94.xx
    Capability:   Bridge, on
    Capability:   Router, on
    Capability:   Wlan, off
    Capability:   Station, off
  Port:        
    PortID:       mac fe:a0:d2:92:52:dc
    PortDescr:    vethWEIQ4p
    TTL:          120
    PMD autoneg:  supported: no, enabled: no
      MAU oper type: 10GigBaseCX4 - X copper over 8 pair 100-Ohm balanced cable
-------------------------------------------------------------------------------
```
Подробнее о протоколе LLDP можно прочитать на странице: http://xgu.ru/wiki/LLDP

3. Какая технология используется для разделения L2-коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.

Ответ: для этого используется VLAN (Virtual Local Area Network), в Debian пакет так и называется `vlan`.
Для работы VLAN необходимо, чтобы был активен модуль ядра `8021q`, чего можно добиться командой `modprobe 8021q`.

Добавим тестовые dummy интерфейсы:
```
ip link add dummy1 type dummy; 
ip link add dummy2 type dummy;
ip link add dummy4 type dummy;
ip link add dummy5 type dummy;
```
Netplan настраивается в соответствии с его документацией:  
https://manpages.ubuntu.com/manpages/kinetic/en/man5/netplan.5.html

Примеры настройки виртуальных VLAN интерфейсов для systemd networkd(Netplan):
```
root@focal-base:/etc/netplan# cat vlan.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    dummy1:
      optional: yes
      addresses: 
        - 192.168.1.2/24
  vlans:
    vlan1:
      id: 123
      link: dummy1
      addresses:
        - 192.168.2.3/24

root@focal-base:/etc/netplan# systemctl restart systemd-networkd
root@focal-base:/etc/netplan# ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0@if16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether da:a8:d7:c4:b2:e1 brd ff:ff:ff:ff:ff:ff link-netnsid 0
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default 
    link/ether 02:42:04:e8:65:09 brd ff:ff:ff:ff:ff:ff
4: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether fe:7e:ed:02:ee:b5 brd ff:ff:ff:ff:ff:ff
5: dummy2: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether e2:ba:67:09:70:2e brd ff:ff:ff:ff:ff:ff
6: vlan1@dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether fe:7e:ed:02:ee:b5 brd ff:ff:ff:ff:ff:ff
root@focal-base:/etc/netplan# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether da:a8:d7:c4:b2:e1 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.3.186/24 brd 10.0.3.255 scope global dynamic eth0
       valid_lft 3595sec preferred_lft 3595sec
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:04:e8:65:09 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
4: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether fe:7e:ed:02:ee:b5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.4/24 brd 192.168.0.255 scope global dummy1
       valid_lft forever preferred_lft forever
    inet 192.168.1.2/24 brd 192.168.1.255 scope global dummy1
       valid_lft forever preferred_lft forever
5: dummy2: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether e2:ba:67:09:70:2e brd ff:ff:ff:ff:ff:ff
6: vlan1@dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether fe:7e:ed:02:ee:b5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.5/24 brd 192.168.1.255 scope global vlan1
       valid_lft forever preferred_lft forever
```

Также можно использовать утилиту `vconfig`: 
```
vconfig add eth0 1 # Добавление VLAN 1 к интерфейсу eth0
vconfig rem vlan1 # Удаление VLAN 1
```

4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.

Решение:
```
root@workstation ~ 19:# > modinfo bonding | grep mode | head -n 1 | sed 's/;/\n/' | sed 's/,/\n/g' | tail -n +2
 0 for balance-rr
 1 for active-backup
 2 for balance-xor
 3 for broadcast
 4 for 802.3ad
 5 for balance-tlb
 6 for balance-alb (charp)
```
Выше мы видим различные режимы работы агрегации, поддерживаемые модулем bonding.
Более подробно с ними можно ознакомиться на странице:  
https://voxlink.ru/kb/linux/rabota-setevyh-interfejsov-v-rezhime-bonding/

[Подробнее об агрегировании каналов](http://xgu.ru/wiki/%D0%90%D0%B3%D1%80%D0%B5%D0%B3%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5_%D0%BA%D0%B0%D0%BD%D0%B0%D0%BB%D0%BE%D0%B2)

Пример настройки bonding для systemd networkd(Netplan):
```
root@focal-base:/etc/netplan# cat bonding.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    dummy1:
      dhcp4: no 
      optional: true
    dummy2: 
      dhcp4: no 
      optional: true
    dummy4:
      dhcp4: no 
      optional: true
    dummy5: 
      dhcp4: no 
      optional: true
      
  bonds:
    bond1_ab: 
      dhcp4: yes 
      interfaces:
        - dummy1
        - dummy2
      parameters:
        mode: active-backup
        primary: dummy1
        mii-monitor-interval: 2
    bond2_alb: 
      dhcp4: no
      interfaces:
        - dummy4
        - dummy5
      parameters:
        mode: balance-alb
        mii-monitor-interval: 2
        root@focal-base:/etc/netplan# 
```

5. Сколько IP-адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.

Ответ:

Количество подсетей /29 можно посчитать по разнице количества бит сетевой части диапазонов /24 и /29:
29-24=5 бит, это значит, что у нас будет 2^5=32 подсети /29 внутри сети /24.

Примеры подсети /29: 10.10.10.0/29, 10.10.10.8/29, 10.10.10.16/29 и т.д. с шагом 8 в последнем октете.


6. Задача: вас попросили организовать стык между двумя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP-адреса? Маску выберите из расчёта — максимум 40–50 хостов внутри подсети.

Воспользуемся RFC6598: https://datatracker.ietf.org/doc/html/rfc6598
```
   IANA has recorded the allocation of an IPv4 /10 for use as Shared
   Address Space. 
   The Shared Address Space address range is 100.64.0.0/10.
```

50 хостов хорошо вписывается в сегмент 2^6=64 адреса, значит маска будет 32-6=26
Проверяем в ipcalc:
```
17:18 root@workstation /download 5:# > ipcalc 100.64.0.0/26
Address:   100.64.0.0           01100100.01000000.00000000.00 000000                                                                                                                                             
Netmask:   255.255.255.192 = 26 11111111.11111111.11111111.11 000000                                                                                                                                             
Wildcard:  0.0.0.63             00000000.00000000.00000000.00 111111                                                                                                                                             
=>                                                                                                                                                                                                               
Network:   100.64.0.0/26        01100100.01000000.00000000.00 000000
HostMin:   100.64.0.1           01100100.01000000.00000000.00 000001
HostMax:   100.64.0.62          01100100.01000000.00000000.00 111110
Broadcast: 100.64.0.63          01100100.01000000.00000000.00 111111
Hosts/Net: 62                    Class A
```
Ответ: можно использовать незанятые подсети /26 с маской 255.255.255.192 сети 100.64.0.0/10.

7. Как проверить ARP-таблицу в Linux, Windows? Как очистить ARP-кеш полностью? Как из ARP-таблицы удалить только один нужный IP?

Решение: Для этого есть команды `ip neigh` и `arp`.
И ответ для Linux:  
```
root@workstation ~ 10:# > arp -a # смотрим таблицу известных MAC адресов
eee (192.168.0.x) at 00:22:15:xx:xx:xx [ether] on eth2

root@workstation ~ 11:# ip -s -s neigh flush all # Удаляем все MAC адреса из ARP кеша.
192.168.0.x dev eth2 lladdr 00:22:15:xx:xx:xx ref 1 used 4/0/4 probes 4 REACHABLE
*** Round 1, deleting 1 entries ***
*** Flush is complete after 1 round ***

root@workstation ~ 12:# > arp --delete eee; arp -a -v; echo "Waiting for ARP table refresh"; sleep 1s; arp -a -v; # Удаляем один адрес
Entries: 0      Skipped: 0      Found: 0
Waiting for ARP table refresh
eee (192.168.0.x) at 00:22:15:xx:xx:xx [ether] on eth2
Entries: 1      Skipped: 0      Found: 1
```

Windows: `arp -a`, `arp -d`.


PS: некоторые части приватных адресов и некоторые номера заменены буквами x,y и т.п.

---

## Задание со звёздочкой* 

Это самостоятельное задание, его выполнение необязательно.

8. Установите эмулятор EVE-ng.
Выполните задания на lldp, vlan, bonding в эмуляторе EVE-ng. 
 
[Инструкция по установке](https://github.com/svmyasnikov/eve-ng).  
Гипервизором VMWare на данный момент я не пользуюсь (в т.ч. ESXi, Workstation и Player), обычно использую виртуалки KVM и LXC с оркестраторами Vagrant и OpenNebula. Нашел описания, как установить на Proxmox:  
https://forum.proxmox.com/threads/run-eve-ng-in-lxc-success.104784/  
https://adamfromthefuture.wordpress.com/2018/08/30/running-eve-ng-under-proxmox/  
https://ru-ru.facebook.com/groups/proxmox/permalink/2564408103587906/  
Думаю, аналогично можно установить и на OpenNebula. Задача очень интересная, но пока заниматься этим совсем некогда, поэтому отложил эту необязательную задачу на потом.