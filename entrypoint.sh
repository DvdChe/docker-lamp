#! /bin/bash

set -eux

usermod www-data -s /bin/bash

# -- Setting Apache conf: --

# Opcache :

{ \
  echo 'opcache.enable=1'; \
  echo 'opcache.enable_cli=1'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=10000'; \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.save_comments=1'; \
  echo 'opcache.revalidate_freq=1'; \
} > /etc/php/7.0/apache2/conf.d/opcache-recommended.ini

# VirtualHost :

mkdir /var/www/"${FQDN}" || true
chown -R www-data: /var/www/"${FQDN}"

{ \
  echo "ServerName ${FQDN}"; \
  echo "<VirtualHost *:80>"; \
  echo "    ErrorLog ${APACHE_LOG_DIR}/${FQDN}-error.log"; \
  echo "    CustomLog ${APACHE_LOG_DIR}/${FQDN}-access.log combined"; \
  echo "    DocumentRoot \"/var/www/${FQDN}/\""; \
  echo "    <Directory /var/www/${FQDN}/>"; \
  echo "      Options +FollowSymlinks -Indexes"; \
  echo "      AllowOverride All"; \
  echo "     <IfModule mod_dav.c>"; \
  echo "      Dav Off"; \
  echo "     </IfModule>"; \
  echo "     SetEnv HOME /var/www/${FQDN}"; \
  echo "     SetEnv HTTP_HOME /var/www/${FQDN}"; \
  echo "    </Directory>"; \
  echo "</VirtualHost>"; \
} > /etc/apache2/sites-available/nextcloud.conf


# MPM_Prefork

ncpu=$(cat /proc/cpuinfo | grep processor | wc -l)
dbncpu=$(($ncpu * 2))
dbncput=$(($ncpu * 2 + 10))

{ \
  echo "<IfModule mpm_prefork_module>"; \
  echo "    StartServers          ${dbncpu}"; \
  echo "    MinSpareServers       ${dbncpu}"; \
  echo "    MaxSpareServers       ${dbncpu}"; \
  echo "    MaxClients            ${dbncput}"; \
  echo "    MaxRequestsPerChild   1000"; \
  echo "</IfModule>"; \
} > /etc/apache2/mods-available/mpm_prefork.conf

# Apache misc conf

{ \
   echo 'ServerSignature Off'; \
   echo 'ServerTokens Prod'; \
} >> /etc/apache2/apache2.conf

#eof Apache conf

# -- Mysql conf --

# Data directory

sed -i 's/datadir.*/datadir = \/var\/lib\/mysql_data/g' /etc/mysql/mariadb.conf.d/50-server.cnf

{ \
   echo 'innodb_buffer_pool_size = 1073741824' ; \
} >> /etc/mysql/mariadb.conf.d/50-server.cnf

# Create user and grants ( only on first run )

if [ ! -f /var/lib/mysql_data/.flag ]; then

    cp -Rv /var/lib/mysql/* /var/lib/mysql_data
    echo "set ownership of /var/lib/mysql_data"

    chown -R mysql: /var/lib/mysql_data

    /etc/init.d/mysql start

    mysql -u root -e "CREATE DATABASE ${DB_NAME};"
    mysql -u root -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"

    touch /var/lib/mysql_data/.flag

fi

rm -rf /var/www/html || true
rm /etc/apache2/sites-enabled/000-default.conf || true
ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf

a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod mime

/etc/init.d/apache2 start
/etc/init.d/mysql start



/bin/bash
