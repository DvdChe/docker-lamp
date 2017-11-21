FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install php7.0 apache2 gnupg wget git zip unzip -y

RUN apt-get update && apt-get install \
	mysql-server \
	php7.0-mysql \
	php-mcrypt \
	php7.0-curl \
	php7.0-gd \	
	php7.0-xml  -y 

RUN mkdir /data

VOLUME /var/www
VOLUME /data

EXPOSE 80
COPY entrypoint.sh /entrypoint.sh
COPY files/000-default.conf /etc/apache2/sites-available/000-default.conf
ENTRYPOINT /entrypoint.sh
