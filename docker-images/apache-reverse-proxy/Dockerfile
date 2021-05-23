FROM php:7.2-apache 

RUN apt-get update && \
    apt-get install -y vim && \
    apt-get install dos2unix

# Copy apache2-foreground to container
COPY apache2-foreground /usr/local/bin
# Launch dos2unix to format script in the right way if executed on Windows
RUN cd /usr/local/bin/ && dos2unix apache2-foreground

# Copy templates folder to container
COPY templates  /var/apache2/templates

# Copy conf folder content to container
COPY conf/ /etc/apache2

# Install required modules (the last 2 modules are for load balancing)
RUN a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests

# Active virtual hosts
RUN a2ensite 000-* 001-*
