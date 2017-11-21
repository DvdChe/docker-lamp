#! /bin/bash

usermod www-data -s /bin/bash

sleep 1

if [ ! -f /var/www/html/.flag ]; then

    rm -rf /var/www/html
    chown -R www-data: /var/www
    su -c 'cd /var/www/html && php install.php' - www-data
    
    touch /var/www/html/.flag
fi 

a2enmod rewrite
/etc/init.d/apache2 start


/bin/bash
