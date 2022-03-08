FROM php:8.1-apache
RUN apt update && apt install -y libxslt1-dev
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install xsl
COPY php.ini /usr/local/etc/php/php.ini
