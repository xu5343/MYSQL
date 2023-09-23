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
echo "time:2019/09/05";
echo -e "\033[32mFor more information visit:\033[0m https://www.yunloc.com/510.html";
echo "+-------------------------+";
if [ ! -e /etc/my.cnf ]; then
echo "/etc/my.cnf does not exist";
exit
fi
cp /etc/my.cnf /etc/my.cnf.bak
sed -i 's/server-id/#server-id/g' /etc/my.cnf
sed -i 's/log-bin/#log-bin/g' /etc/my.cnf
read -p "Please enter the database root password:" rootpasswd
if [ "${rootpasswd}" == "" ]; then
echo "The database root password can not be empty";
exit
fi
read -p "Enter the server Ip:" server_ip
if [ "${server_ip}" == "" ]; then
echo "Server ip can not be empty";
exit
fi
read -p "Enter the backup copy user:" backup_user
if [ "${backup_user}" == "" ]; then
echo "Backup replication users can not be empty";
exit
fi
read -p "Backup copy user password:" backup_user_password
if [ "${backup_user_password}" == "" ]; then
echo "The backup copy user password can not be empty";
exit
fi
read -p "Fill in the value of File (For example: mysql-bin.xxxxxx):" mysql_bin
if [ "${mysql_bin}" == "" ]; then
echo "The value of File can not be empty";
exit
fi
read -p "Position value (for example: 107):" Position
if [ "${Position}" == "" ]; then
echo "The value of Position can not be empty";
exit
fi
read -p "Please enter service ID:" Service_ID
if [[ "${Service_ID}" != "" ]] && [[ "${Service_ID}" != "0" ]] && [[ "${Service_ID}" != [!0123456789] ]]; then
#read -p "Enter the name of the database to be synchronized:" Database_name
#if [ "${Database_name}" == "" ]; then
#echo "The synchronization database name can not be empty";
#else
sed -i '/skip-external-locking/a\read_only' /etc/my.cnf
#sed -i '/skip-external-locking/a\'binlog-do-db=$Database_name'' /etc/my.cnf
sed -i '/skip-external-locking/a\binlog-ignore-db=mysql' /etc/my.cnf
sed -i '/skip-external-locking/a\log-bin=mysql-bin' /etc/my.cnf
sed -i '/skip-external-locking/a\'server-id=$Service_ID'' /etc/my.cnf
service mysql restart 1>/dev/null 2>&1
service mysqld restart 1>/dev/null 2>&1
mysql -uroot -p${rootpasswd} -e "show variables like 'server_id';stop slave";
mysql -uroot -p${rootpasswd} -e "change master to master_host='$server_ip',master_user='$backup_user',master_password='$backup_user_password',master_log_file='$mysql_bin' ,master_log_pos=$Position";
mysql -uroot -p${rootpasswd} -e "start slave;SHOW SLAVE STATUS\G";
#fi
else
echo "The service id can only be a number";
fi
}
old_mycnf()
{
if [ ! -e /etc/my.cnf.bak ]; then
echo "/etc/my.cnf.bak does not exist";
exit
fi
rm -rf /etc/my.cnf
mv /etc/my.cnf.bak /etc/my.cnf
service mysql restart 1>/dev/null 2>&1
service mysqld restart 1>/dev/null 2>&1
echo -e "Tip:\033[32mThe database started successfully\033[0m"
}
case "${Stack}" in
    default)
        default
        ;;
    old)
		old_mycnf
        ;;
    *)
       echo "Usage: $0 {default|old}"
        ;;
esac