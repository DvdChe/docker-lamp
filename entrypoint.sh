#! /bin/bash

usermod www-data -s /bin/bash


if [ ! -f /var/lib/mysql_data/.flag ]; then
	chown -R www-data: /var/www
	cp -Rv /var/lib/mysql/* /var/lib/mysql_data
	chown -R mysql: /var/lib/mysql_data/
	touch /var/lib/mysql_data/.flag
fi


a2enmod rewrite
/etc/init.d/mysql start
/etc/init.d/apache2 start


/bin/bash
