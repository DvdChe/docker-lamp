FROM debian:stretch-slim    

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install php7.0 apache2 gnupg wget git zip unzip -y

RUN apt-get update && apt-get install \
	mysql-server \
	php7.0-mysql \
	php-mcrypt \
	php7.0-curl \
	php7.0-gd \	
	php7.0-xml -y --no-install-recommends

RUN mkdir /data

VOLUME /var/www
VOLUME /var/lib/mysql_data

EXPOSE 80
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
