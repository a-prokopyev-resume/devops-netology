# [Домашнее задание](https://github.com/a-prokopyev-resume/sysadm-homeworks/tree/devsys10/03-sysadmin-05-fs) к занятию [«Файловые системы»](https://netology.ru/profile/program/sys-dev-27/lessons/242280/lesson_items/1286601)

### Цель задания

В результате выполнения задания вы: 

* научитесь работать с инструментами разметки жёстких дисков, виртуальных разделов — RAID-массивами и логическими томами, конфигурациями файловых систем. Основная задача — понять, какие слои абстракций могут нас отделять от файловой системы до железа. Обычно инженер инфраструктуры не сталкивается напрямую с настройкой LVM или RAID, но иметь понимание, как это работает, необходимо;
* создадите нештатную ситуацию работы жёстких дисков и поймёте, как система RAID обеспечивает отказоустойчивую работу.

### Чеклист готовности к домашнему заданию

1. Убедитесь, что у вас на новой виртуальной машине установлены утилиты: `mdadm`, `fdisk`, `sfdisk`, `mkfs`, `lsblk`, `wget` (шаг 3 в задании).  
2. Воспользуйтесь пакетным менеджером apt для установки необходимых инструментов.

### Дополнительные материалы для выполнения задания

1. Разряженные файлы — [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB).
2. [Подробный анализ производительности RAID](https://www.baarf.dk/BAARF/0.Millsap1996.08.21-VLDB.pdf), страницы 3–19.
3. [RAID5 write hole](https://www.intel.com/content/www/us/en/support/articles/000057368/memory-and-storage.html).


------

## Выполнение задания.

1. Узнайте о sparse-файлах. 

Ответ: sparse файлы позволяют сократить реальное потребление дискового пространства для файлов, содержащих много последовательных нулей, 
за счет хранения фрагментов из последовательных нулевых значений в виде записей о них в метаданных файла.

2. Могут ли файлы, являющиеся жёсткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Ответ: Жесткие ссылки не могут иметь разные права доступа и владельца, потому что это только разные имена для одного и того же inode, 
а почти вся информация о файле, включая права доступа к нему, хранится в inode, а не в жестких ссылках.

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

Ответ: Новую виртуальную машину создал.

4. Используя `fdisk`, разбейте первый диск на два раздела: 2 Гб и оставшееся пространство.

Решение:
/dev/sdl и /dev/sdm - символические ссылки на ZFS volumes.
```
root@focal-base:/dev# fdisk -l /dev/sdl
Disk /dev/sdl: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 8192 bytes
I/O size (minimum/optimal): 8192 bytes / 8192 bytes
Disklabel type: dos
Disk identifier: 0x130d8625

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdl1          2048 4196351 4194304    2G 83 Linux
/dev/sdl2       4196352 5242879 1046528  511M 83 Linux
```

5. Используя `sfdisk`, перенесите эту таблицу разделов на второй диск.

Решение: копируем дамп разметки с первого диска на второй через pipe: 
```
root@focal-base:/# sfdisk --dump /dev/sdl | sfdisk /dev/sdm
Checking that no-one is using this disk right now ... OK

Disk /dev/sdm: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 8192 bytes
I/O size (minimum/optimal): 8192 bytes / 8192 bytes
Disklabel type: dos
Disk identifier: 0x130d8625

Old situation:

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdm1          2048 4196351 4194304    2G 83 Linux
/dev/sdm2       4196352 5242879 1046528  511M 83 Linux

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x130d8625.
/dev/sdm1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdm2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdm3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x130d8625

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdm1          2048 4196351 4194304    2G 83 Linux
/dev/sdm2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
root@focal-base:/# fdisk -l /dev/sdm
Disk /dev/sdm: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 8192 bytes
I/O size (minimum/optimal): 8192 bytes / 8192 bytes
Disklabel type: dos
Disk identifier: 0x130d8625

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdm1          2048 4196351 4194304    2G 83 Linux
/dev/sdm2       4196352 5242879 1046528  511M 83 Linux
```

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

Решение:
```
root@kube:/# mdadm --create --verbose /dev/md/raid1 --level=1 --raid-devices=2 /dev/sdl1 /dev/sdm1
mdadm: Note: this array has metadata at the start and                                                                                                                                                            
    may not be suitable as a boot device.  If you plan to                                                                                                                                                        
    store '/boot' on this device please ensure that                                                                                                                                                              
    your boot-loader understands md/v1.x metadata, or use                                                                                                                                                        
    --metadata=0.90                                                                                                                                                                                              
mdadm: size set to 2094080K                                                                                                                                                                                      
Continue creating array? y                                                                                                                                                                                       
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md/raid1 started.
root@kube:/# ls -al /dev/m
mapper/ mcelog  md/     md127   mem     
root@kube:/# ls -al /dev/md/raid1 
lrwxrwxrwx 1 root root 8 May 17 12:14 /dev/md/raid1 -> ../md127
```

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

Решение:
```
root@kube:/ mdadm --create --verbose /dev/md/raid0 --level=0 --raid-devices=2 /dev/sdl2 /dev/sdm2
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md/raid0 started.

root@kube:/# mdadm --detail --scan 
ARRAY /dev/md/raid1 metadata=1.2 name=kube:raid1 UUID=f9ef9b5f:839c8521:e4b92403:2e622fce
ARRAY /dev/md/raid0 metadata=1.2 name=kube:raid0 UUID=def13e33:48ec6536:108084cc:d51250b3

```

8. Создайте два независимых PV на получившихся md-устройствах.

Решение:
```
root@kube:/download# pvcreate /dev/md/raid0
  Physical volume "/dev/md/raid0" successfully created.

root@kube:/download# pvcreate /dev/md/raid1
  Physical volume "/dev/md/raid1" successfully created.

root@kube:/download# pvs
  PV         VG Fmt  Attr PSize    PFree   
  /dev/md126    lvm2 ---  1018.00m 1018.00m
  /dev/md127    lvm2 ---    <2.00g   <2.00g
```

9. Создайте общую volume-group на этих двух PV.

Решение:
```
root@kube:/# vgcreate test_vol_group /dev/md126 /dev/md127
  Volume group "test_vol_group" successfully created

root@kube:/# vgs
  VG             #PV #LV #SN Attr   VSize  VFree 
  test_vol_group   2   0   0 wz--n- <2.99g <2.99g

root@kube:/# vgs --verbose
  VG             Attr   Ext   #PV #LV #SN VSize  VFree  VG UUID                                 VProfile
  test_vol_group wz--n- 4.00m   2   0   0 <2.99g <2.99g 0Eipys-vn5R-G8di-sg8D-5tmP-n5uX-3UsTHn
  
root@kube:/# pvdisplay
  --- Physical volume ---
  PV Name               /dev/md126
  VG Name               test_vol_group
  PV Size               1018.00 MiB / not usable 2.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              254
  Free PE               254
  Allocated PE          0
  PV UUID               86vfOT-UDjD-m0r9-wKNF-AwhE-nKfd-WFrn9E
   
  --- Physical volume ---
  PV Name               /dev/md127
  VG Name               test_vol_group
  PV Size               <2.00 GiB / not usable 0   
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              511
  Free PE               511
  Allocated PE          0
  PV UUID               KbXWde-aeUA-gsdV-bsCq-d0t3-YrK7-FRL8CZ
```

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

Решение:
```
root@kube:~# lvcreate --name 100mb_lv -L 100M test_vol_group  /dev/md/raid0
  Logical volume "100mb_lv" created.
root@kube:~# lvdisplay 
  --- Logical volume ---
  LV Path                /dev/test_vol_group/100mb_lv
  LV Name                100mb_lv
  VG Name                test_vol_group
  LV UUID                UE3LK5-0n1d-3egA-69Kq-2JMv-3Hdo-ywKQpp
  LV Write Access        read/write
  LV Creation host, time kube, 2023-05-17 16:53:19 +0500
  LV Status              available
  # open                 0
  LV Size                100.00 MiB
  Current LE             25
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     4096
  Block device           253:0

```

11. Создайте `mkfs.ext4` ФС на получившемся LV.

Решение:
```
root@kube:~# mkfs.ext4 /dev/test_vol_group/100mb_lv
mke2fs 1.46.6 (1-Feb-2023)
Discarding device blocks: done                            
Creating filesystem with 102400 1k blocks and 25584 inodes
Filesystem UUID: 7a6d41d8-9f29-4fbc-91a5-19cd1156219d
Superblock backups stored on blocks: 
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

root@kube:~# fsck -f /dev/test_vol_group/100mb_lv
fsck from util-linux 2.36.1
e2fsck 1.46.6 (1-Feb-2023)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/mapper/test_vol_group-100mb_lv: 11/25584 files (0.0% non-contiguous), 12081/102400 blocks
```

12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

Решение:
```
root@kube:~# mkdir /mnt/new
root@kube:~# mount /dev/test_vol_group/100mb_lv /mnt/new
root@kube:~# mount | grep 100mb
/dev/mapper/test_vol_group-100mb_lv on /mnt/new type ext4 (rw,relatime,stripe=1024)
```

13. Поместите туда тестовый файл, например, `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

Решение:
```
root@kube:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /mnt/new/test.gz
--2023-05-17 16:57:02--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 24992929 (24M) [application/octet-stream]
Saving to: ‘/mnt/new/test.gz’

/mnt/new/test.gz               100%[==================================================>]  23.83M  14.5MB/s    in 1.6s    

2023-05-17 16:57:05 (14.5 MB/s) - ‘/mnt/new/test.gz’ saved [24992929/24992929]
```

14. Прикрепите вывод `lsblk`.

Решение:
```
root@kube:~# lsblk | grep zd16 -A 10
zd16                          230:16   0   2.5G  0 disk  
├─zd16p1                      230:17   0     2G  0 part  
│ └─md127                       9:127  0     2G  0 raid1 
└─zd16p2                      230:18   0   511M  0 part  
  └─md126                       9:126  0  1018M  0 raid0 
    └─test_vol_group-100mb_lv 253:0    0   100M  0 lvm   /mnt/new
zd32                          230:32   0   2.5G  0 disk  
├─zd32p1                      230:33   0     2G  0 part  
│ └─md127                       9:127  0     2G  0 raid1 
└─zd32p2                      230:34   0   511M  0 part  
  └─md126                       9:126  0  1018M  0 raid0 
    └─test_vol_group-100mb_lv 253:0    0   100M  0 lvm   /mnt/new
```


15. Протестируйте целостность файла.

Решение:
```
root@kube:~# gzip --test --verbose /mnt/new/test.gz; echo $?
/mnt/new/test.gz:        OK
0
```

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

Решение:
```
root@kube:~# pvmove /dev/md/raid0 /dev/md/raid1 
  /dev/md/raid0: Moved: 12.00%
  /dev/md/raid0: Moved: 100.00%

root@kube:~# lsblk | grep zd16 -A 10
zd16                          230:16   0   2.5G  0 disk  
├─zd16p1                      230:17   0     2G  0 part  
│ └─md127                       9:127  0     2G  0 raid1 
│   └─test_vol_group-100mb_lv 253:0    0   100M  0 lvm   /mnt/new
└─zd16p2                      230:18   0   511M  0 part  
  └─md126                       9:126  0  1018M  0 raid0 
zd32                          230:32   0   2.5G  0 disk  
├─zd32p1                      230:33   0     2G  0 part  
│ └─md127                       9:127  0     2G  0 raid1 
│   └─test_vol_group-100mb_lv 253:0    0   100M  0 lvm   /mnt/new
└─zd32p2                      230:34   0   511M  0 part  
  └─md126                       9:126  0  1018M  0 raid0 
```
17. Сделайте `--fail` на устройство в вашем RAID1 md.

Решение:
```
root@kube:~# mdadm /dev/md/raid1 --fail /dev/zd32p1 
mdadm: set /dev/zd32p1 faulty in /dev/md/raid1
```
18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

Решение:
```
root@kube:~# dmesg 
[216177.402101] md/raid1:md127: Disk failure on zd32p1, disabling device.
                md/raid1:md127: Operation continuing on 1 devices.
```
19. Протестируйте целостность файла — он должен быть доступен несмотря на «сбойный» диск:

Решение:
```
root@kube:~# gzip --test --verbose /mnt/new/test.gz; echo $?
/mnt/new/test.gz:        OK
0
```

20. Погасите тестовый хост — `vagrant destroy`.

Решение: Выполнил.
 
