#!/bin/bash

chown mysql:mysql /var/lib/mysql
chown mysql:mysql /var/log/mysql

if [ "$(ls -A /var/lib/mysql)" ]; then
	echo "Datadir is not empty! Trying to use it."
else
	mysqld --initialize
fi

/usr/sbin/mysqld \
  --basedir=/usr \
  --datadir=/var/lib/mysql \
  --plugin-dir=/usr/lib/mysql/plugin \
  --log-error=/var/log/mysql/error.log \
  --pid-file=/var/run/mysqld/mysqld.pid \
  --socket=/var/run/mysqld/mysqld.sock \
  --port=3306 &

if [ "$(ls -A /var/lib/mysql)" ]; then
	echo "Datadir is not empty! Trying to use it."
else
    sleep 5 &&
        mysql --connect-expired-password -u root -p`grep 'temporary password' /var/log/mysql/error.log |awk '{print $(NF)}'` -e "ALTER user 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD'" &&
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD'"
fi

tail -f /var/log/mysql/error.log


