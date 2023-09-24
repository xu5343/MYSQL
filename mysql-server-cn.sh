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
echo "时间:2019/09/05";
echo -e "\033[32m更多信息请访问:\033[0m https://www.baidu.com/";
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
read -p "请输入服务器IP:" server_ip
if [ "${server_ip}" == "" ]; then
echo "服务器IP不能为空";
exit
fi
read -p "请输入从用户名:" backup_user
if [ "${backup_user}" == "" ]; then
echo "从用户不能为空";
exit
fi
read -p "从用户密码:" backup_user_password
if [ "${backup_user_password}" == "" ]; then
echo "从用户密码不能为空";
exit
fi
read -p "填写File的值（例如: mysql-bin.xxxxxx）:" mysql_bin
if [ "${mysql_bin}" == "" ]; then
echo "File的值不能为空";
exit
fi
read -p "填写Position的值（例如: 107）:" Position
if [ "${Position}" == "" ]; then
echo "Position的值不能为空";
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
read -p "是否将数据库设置为只读模式?（yes/no）:" read_only_choice
if [ "${read_only_choice}" == "yes" ]; then
  sed -i '/skip-external-locking/a\read_only' /etc/my.cnf
elif [ "${read_only_choice}" == "no" ]; then
  sed -i '/skip-external-locking/a\read_only=OFF' /etc/my.cnf
else
  echo "输入无效，请输入yes或no"
  exit
fi
sed -i '/skip-external-locking/a\log-bin=mysql-bin' /etc/my.cnf
sed -i "/skip-external-locking/a\\server-id=${Service_ID}" /etc/my.cnf
service mysql restart 1>/dev/null 2>&1
service mysqld restart 1>/dev/null 2>&1
mysql -uroot -p${rootpasswd} -e "show variables like 'server_id';stop slave";
mysql -uroot -p${rootpasswd} -e "change master to master_host='$server_ip',master_user='$backup_user',master_password='$backup_user_password',master_log_file='$mysql_bin' ,master_log_pos=$Position";
mysql -uroot -p${rootpasswd} -e "start slave;SHOW SLAVE STATUS\G";
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
