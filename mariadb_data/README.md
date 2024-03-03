
레드마인 데이터베이스 이행

root@ict-pmo-dev-192-168-219-106:/data/redmine/mariadb_data# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS         PORTS                                       NAMES
dd4da311f5cf   choipro/redmine:4.2.3-5plugins   "/opt/bitnami/script??   20 minutes ago   Up 3 minutes   0.0.0.0:8088->3000/tcp, :::8088->3000/tcp   redmine_redmine_1
52bf642a0792   bitnami/mariadb:10.1             "/opt/bitnami/script??   20 minutes ago   Up 3 minutes   3306/tcp                                    redmine_mariadb_1

root@ict-pmo-dev-192-168-219-106:/data/redmine/mariadb_data# docker exec -it 52bf642a0792 /bin/bash
I have no name!@52bf642a0792:/$ mysql -uroot -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 9
Server version: 10.1.47-MariaDB Source distribution
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases ;
+--------------------+
| Database           |
+--------------------+
| bitnami_redmine    |
| information_schema |
| mysql              |
| performance_schema |
| test               |
+--------------------+
5 rows in set (0.00 sec)

MariaDB [(none)]> drop database bitnami_redmine ;
Query OK, 94 rows affected (2.96 sec)

MariaDB [(none)]> create database bitnami_redmine ;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> exit
Bye


I have no name!@52bf642a0792:/$ df 
Filesystem     1K-blocks     Used Available Use% Mounted on
overlay         24169608 17366332   5552460  76% /
tmpfs              65536        0     65536   0% /dev
tmpfs            4083804        0   4083804   0% /sys/fs/cgroup
/dev/sda2       24169608 17366332   5552460  76% /bitnami/mariadb
shm                65536        0     65536   0% /dev/shm
tmpfs            4083804        0   4083804   0% /proc/acpi
tmpfs            4083804        0   4083804   0% /proc/scsi
tmpfs            4083804        0   4083804   0% /sys/firmware
I have no name!@52bf642a0792:/$ cd /bitnami/mariadb/
I have no name!@52bf642a0792:/bitnami/mariadb$ ls -al
total 392440
drwxrwxr-x 3 root root      4096 Mar  3 09:13 .
drwxr-xr-x 3 root root      4096 Oct 28  2020 ..
-rw-rw-r-- 1 root root         0 Mar  3 08:44 .gitkeep
-rw-r--r-- 1 root root  45167418 Mar  3 09:13 bitnami_redmineplusagile.sql
drwxr-xr-x 6 1001 root      4096 Mar  3 09:14 data
I have no name!@52bf642a0792:/bitnami/mariadb$ mysql -uroot -p bitnami_redmine < bitnami_redmineplusagile.sql 
Enter password: 
