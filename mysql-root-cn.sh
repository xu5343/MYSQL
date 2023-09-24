#!/bin/bash
Stack=$1
if [ "${Stack}" = "" ]; then
    Stack="default"
else
    Stack=$1
fi
default()
{
echo "+-------------------------+";
echo "时间:2023/09/24";
echo -e "\033[32m更多信息请访问:\033[0m https://www.yunloc.com/510.html";
echo "+-------------------------+";
if [ ! -e /etc/my.cnf ]; then
echo "/etc/my.cnf 文件不存在";
exit
fi
cp /etc/my.cnf /etc/my.cnf.bak
sed -i 's/server-id/#server-id/g' /etc/my.cnf
sed -i 's/log-bin/#log-bin/g' /etc/my.cnf
read -p "请输入数据库root密码:" rootpasswd
if [ "${rootpasswd}" == "" ]; then
echo "数据库root密码不能为空";
exit
fi
read -p "创建一个数据库备份用户:" backup_user
if [ "${backup_user}" == "" ]; then
echo "数据库备份用户不能为空";
exit
fi
read -p "数据库备份用户密码:" backup_user_password
if [ "${backup_user_password}" == "" ]; then
echo "数据库备份用户密码不能为空";
exit
fi
read -p "请输入服务ID:" Service_ID
if [[ "${Service_ID}" != "" ]] && [[ "${Service_ID}" != "0" ]] && [[ "${Service_ID}" != [!0123456789] ]]; then
read -p "输入要同步的数据库名称（留空表示同步所有数据库）:" Database_name
if [ "${Database_name}" == "" ]; then
sed -i '/skip-external-locking/a\binlog-ignore-db=mysql' /etc/my.cnf
else
sed -i "/skip-external-locking/a\\binlog-do-db=${Database_name}" /etc/my.cnf
fi
sed -i '/skip-external-locking/a\log-bin=mysql-bin' /etc/my.cnf
sed -i "/skip-external-locking/a\\server-id=${Service_ID}" /etc/my.cnf
service mysql restart 1>/dev/null 2>&1
service mysqld restart 1>/dev/null 2>&1
mysql -uroot -p${rootpasswd} -e "grant replication slave  on *.* to '$backup_user'@'%' identified by '$backup_user_password' with grant option";
mysql -uroot -p${rootpasswd} -e "show variables like 'server_id';show master status";
else
echo "服务ID只能是数字";
fi
}
old_mycnf()
{
if [ ! -e /etc/my.cnf.bak ]; then
echo "/etc/my.cnf.bak 文件不存在";
exit
fi
rm -rf /etc/my.cnf
mv /etc/my.cnf.bak /etc/my.cnf
service mysql restart 1>/dev/null 2>&1
service mysqld restart 1>/dev/null 2>&1
echo -e "提示:\033[32m数据库启动成功\033[0m"
}
case "${Stack}" in
    default)
        default
        ;;
    old)
		old_mycnf
        ;;
    *)
       echo "使用方法: $0 {default|old}"
        ;;
esac
