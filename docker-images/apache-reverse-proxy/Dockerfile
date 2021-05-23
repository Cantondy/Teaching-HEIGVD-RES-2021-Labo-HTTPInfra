FROM php:7.2-apache 

#Install vim
RUN apt-get update && \
    apt-get install -y vim

COPY conf/ /etc/apache2
#install required modules
RUN a2enmod proxy proxy_http
#active virtual hosts
RUN a2ensite 000-* 001-*