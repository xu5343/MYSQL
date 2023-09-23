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
echo "time:2019/05/05";
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
read -p "Create a database backup user:" backup_user
if [ "${backup_user}" == "" ]; then
echo "The database backup user can not be empty";
exit
fi
read -p "Database backup user password:" backup_user_password
if [ "${backup_user_password}" == "" ]; then
echo "The database backup user password can not be empty";
exit
fi
read -p "Please enter service ID:" Service_ID
if [[ "${Service_ID}" != "" ]] && [[ "${Service_ID}" != "0" ]] && [[ "${Service_ID}" != [!0123456789] ]]; then
#read -p "Enter the name of the database to be synchronized:" Database_name
if [ "${Database_name}" == "" ]; then
#echo "The synchronization database name can not be empty";
#else
#sed -i '/skip-external-locking/a\'binlog-do-db=$Database_name'' /etc/my.cnf
sed -i '/skip-external-locking/a\binlog-ignore-db=mysql' /etc/my.cnf
sed -i '/skip-external-locking/a\log-bin=mysql-bin' /etc/my.cnf
sed -i '/skip-external-locking/a\'server-id=$Service_ID'' /etc/my.cnf
service mysql restart 1>/dev/null 2>&1
service mysqld restart 1>/dev/null 2>&1
mysql -uroot -p${rootpasswd} -e "grant replication slave  on *.* to '$backup_user'@'%' identified by '$backup_user_password' with grant option";
mysql -uroot -p${rootpasswd} -e "show variables like 'server_id';show master status";
fi
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
