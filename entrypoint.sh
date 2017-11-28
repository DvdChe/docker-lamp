#! /bin/bash

usermod www-data -s /bin/bash
/etc/init.d/apache2 start


if [ ! -f /var/lib/mysql_data/.flag ]; then
	chown -R www-data: /var/www
	cp -Rv /var/lib/mysql/* /var/lib/mysql_data
	chown -R mysql: /var/lib/mysql_data/

    /etc/init.d/mysql start
    sleep 5

    mysql -u root -e "CREATE DATABASE ${DB_NAME};"
    mysql -u root -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"

    touch /var/lib/mysql_data/.flag

else
    /etc/init.d/mysql start
fi


/bin/bash
