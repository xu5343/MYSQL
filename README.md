# 使用脚本自动配置MYSQL数据库主从同步和主和主相互同步就是（双主） 支持lnmp/宝塔环境
![Image text](https://raw.githubusercontent.com/xu5343/MYSQL/34a2f3c6aab9c36968fbcc66c1b0ebad9c353c71/mysql.png)  
### 前言
很多同学觉得配置 mysql 主从同步很复杂，下面我在网上淘了个脚本（貌似没有出处）使配置 Mysql 主从同步变得很简单了，经测试支持 lnmp 和 wdcp宝塔环境！配合RSYNC 实用配置脚本 增量备份你的 VPS 主机可同时备份网站数据。  

### 使用教程
本脚本合适空数据库，如果有数据的请先把需要同步的数据库进行锁定,导出数据库上传到从服务器还原到需要同步的数据库再执行如下两个脚本。操作完成后再解锁主服务器的数据库。（如数据库有数据的建议先进行备份再操作）  
### 目前测试支持mysql5.7、mysql5.6,其他版本没有测试，有条件大家可以去测试一下
登录主服务器和从服务器数据库,输入数据库密码
~~~
mysql -u root -p
~~~

锁定 Mysql 数据库，待完成同步后再解锁数据库（解锁命令在后面）
~~~
flush tables with read lock;
~~~
退出 Mysql，exit 或者直接 Ctrl+c
~~~
exit
~~~
输入 Mysql 的 root 密码，备份（主服务器）数据库后传到（从）服务器
~~~
/usr/local/mysql/bin/mysqldump -u root -p 数据库名 > 数据库名.sql
~~~
登录你的从服务器，输入 Mysql 的 root 密码，把备份数据库导入从服务器
~~~
/usr/local/mysql/bin/mysql -u root -p 数据库名 < 数据库名.sql
~~~
## 下载（主服务器）脚本执行
 wget 执行脚本

 国外：  
~~~
wget https://raw.githubusercontent.com/xu5343/MYSQL/main/mysql-root.sh && chmod +x mysql-root.sh && sh mysql-root.sh
~~~
国内：  
~~~
wget https://dl.yunloc.com/Shell/mysql/mysql-root.sh && chmod +x mysql-root.sh && sh mysql-root.sh
~~~
第一步：输入主服务器 mysql root 密码

Please enter the database root password:

第二步：创建备份复制用户

Create a database backup user:

第三步：输入创建备份复制用户的密码

Database backup user password:

第三步：填写 server-id 默认为：1

Please enter service ID:  
![Image text](https://raw.githubusercontent.com/xu5343/MYSQL/34a2f3c6aab9c36968fbcc66c1b0ebad9c353c71/2019050512250171.png)  
File 值：mysql-bin.000033 Position 值：272 请记好，下面配置从服务器需要用到。  

## 下载（从服务器）脚本执行

wget 执行脚本
国外：  
~~~
wget https://raw.githubusercontent.com/xu5343/MYSQL/main/mysql-server.sh && chmod +x mysql-server.sh && sh mysql-server.sh
~~~
国内：  
~~~
wget https://dl.yunloc.com/Shell/mysql/mysql-server.sh && chmod +x mysql-server.sh && sh mysql-server.sh
~~~
第一步：输入从服务器 mysql root 密码

Please enter the database root password:

第二步：输入主服务器 ip:172.96.xxx.xx

Enter the server Ip:

第三步：输入备份复制用户名，或在主服务器上 ssh 上复制过来

Enter the backup copy user:

第四步：输入备份复制用户的密码，或在主服务器 ssh 上复制过来

Backup copy user password:

第五步：输入 Fill 值，例如：mysql-bin.000033，从你的主服务器 ssh 上复制过来

Fill in the value of File (For example: mysql-bin.xxxxxx):

第六步：输入 Position 值，例如：272 ，从你的主服务器 ssh 上复制过来

Position value (for example: 107):

第七步：填写 server-id，id 值要比主服务器大就可以了，一般为 2

Please enter service ID:

执行完脚本后注意查看注意查看下面 2 个值是否为 Yes：表示完成 Mysql 同步了！

Slave_IO_Running: Yes

Slave_SQL_Running: Yes

同步完成后，主从都解除 Mysql 锁定
~~~
unlock tables;
~~~
## 下载（双主方式服务），在过程中反过来操作即可
把上面过程是，主>>到>从，然后要实现双主，在从服务执行主脚本，原来的主服务，执行从脚本，即可实现双主(server-id不能和之前的一样设置新的id)  
主>>到>>从  
从<<到<<主

### 常见错误

Slave_IO_Running: Connecting
Slave_SQL_Running: Yes
1、由于配置好后存在链接主服务器延迟可能会出现 Slave_IO_Running: Connecting，请使用登录mysql请台重新查询状态;
~~~
mysql -u root -p
SHOW SLAVE STATUS\G;
~~~
2、如果出现，无法写入提示：#1290 - The MySQL server is running with the --read-only option so it cannot execute this statement;  
关闭只读模式：如果你确实需要在从服务器上执行写操作，你可以临时关闭只读模式
~~~
mysql -u root -p
SET GLOBAL read_only = OFF;
~~~

如果你想永久关闭只读模式，你需要在MySQL的配置文件（通常是/etc/my.cnf或/etc/mysql/my.cnf）中找到read_only选项并将其设置为OFF，然后重启MySQL服务
~~~
#read_only
read_only = OFF
~~~


3、服务器或者云服务器商的安全组和系统防火墙开放 3306 端口，造成无法同步成功，解决办法：

CentOS6 7 关闭 SELinux,修改文件/etc/selinux/config ，设置后需要重启才能生效
~~~
# SELINUX=enforcing           //注释掉   
SELINUX=disabled             //增加
~~~

### centOS 6 关闭防火墙
关闭命令:
~~~
service iptables stop
~~~
永久关闭防火墙:
~~~
chkconfig iptables off
~~~
查看防火墙关闭状态:
~~~
service iptables status
~~~
### centOS 7 关闭 firewall
查看默认防火墙状态（关闭后显示 notrunning，开启后显示 running）
~~~
firewall-cmd --state
~~~
停止 firewall
~~~
systemctl stop firewalld.service
~~~
禁止 firewall 开机启动 (需重启)
~~~
systemctl disable firewalld.service
~~~
进入 Mysql 输入密码：
~~~
mysql -u root -p
~~~
mysql 主从关闭同步(stop slave)后再打开(start slave)
~~~
stop slave;
start slave;
~~~
登录数据库执行下面的命令重新查看状态是否为 yes
~~~
SHOW SLAVE STATUS\G
~~~
MySQL 取消主从同步
主服务器进入 mysql
~~~
slave stop;
reset slave;
change master to master_host=' ';
~~~
即可成功删除主服务器同步用户信息。

从服务器进入 mysql
~~~
stop slave;
reset slave all;
~~~
再查看同步状态则为空
~~~
show slave status\G;
~~~
Empty set (0.00 sec)


ERROR: No query specified

### 结语
到这里就全部调试完成！


# #教程# 监控MYSQL进程有故障则自动重启脚本

## 前言
### 监控 MYSQL 进程的脚本，故障则重启，如无法启动则 Email 通知;

功能
监控 MYSQL 进程，故障则重启，如无法启动则 Email 通知
~~~
#!/bin/bash
#/usr/bin/nmap localhost | grep 3306
#lsof -i:3306
MYSQLPORT=`netstat -na|grep "LISTEN"|grep "3306"|awk -F[:" "]+ '{print $5}'`
 
function checkMysqlStatus(){
  /usr/bin/mysql -uroot -p11111 --connect_timeout=5 -e "show databases;" &>/dev/null 2>&1
  if [ $? -ne 0 ]
  then
    restartMysqlService
    if [ "$MYSQLPORT" == "3306" ];then
      echo "mysql restart successful......" 
    else
      echo "mysql restart failure......"
      echo "Server: $MYSQLIP mysql is down, please try to restart mysql by manual!" > /var/log/mysqlerr
      #mail -s "WARN! server: $MYSQLIP  mysql is down" info@yunloc.com < /var/log/mysqlerr
    fi
  else
    echo "mysql is running..."
  fi
}
 
function restartMysqlService(){
  echo "try to restart the mysql service......"
  /bin/ps aux |grep mysql |grep -v grep | awk '{print $2}' | xargs kill -9
  service mysql start
}
 
if [ "$MYSQLPORT" == "3306" ]
then
  checkMysqlStatus
else
  restartMysqlService
fi
~~~
把脚本保存为 mysql_status.sh，这里建议每十分钟运行一次
~~~
*/10 * * * * /root/mysql_status.sh
~~~
结语
先检测 MYSQL 的 3306 端口是否正常；

使用帐号连接数据库并执行 show databases 命令；

如以上两点都能正常工作则表示数据库运行正常。
