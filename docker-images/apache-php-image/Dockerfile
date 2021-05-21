FROM php:7.2-apache

RUN apt-get update && \
    apt-get install -y vim

#Copy content of "content" folder into the container
#Files for static website are in folder "content"
COPY content/ /var/www/html/
