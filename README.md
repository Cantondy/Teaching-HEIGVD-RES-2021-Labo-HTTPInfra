# Teaching-HEIGVD-RES-2021-Labo-HTTPInfra

###### Alessando Parrino & Dylan Canton

###### 21.05.2021

---

### Dynamic reverse proxy configuration

#### Purpose

The reverse proxy currently in place uses fixed IP addresses. The goal is to make the management of these addresses dynamic to adapt to the change of container addresses by passing the addresses via the `-e` flag of the` docker run` command and by executing a custom script in order to retrieve the environment variables to generate a configuration file. 



#### Implementation

First of all we create an `apache2-foreground` file in the same folder as the ` Dockerfile`. Its content is taken from the official PHP docker git : https://github.com/docker-library/php/blob/master/apache2-foreground 

We add the following lines in order to display the environment variables passed as a parameter of the `docker run` command with the` -e` flag. 

```sh
# Add setup for RES lab
echo "Setup for the RES lab..."
echo "Static App URL: $STATIC_APP"
echo "Dynamic App URL: $DYNAMIC_APP"
```

We add this line too in order to allows to copy the configuration file generated in PHP into the container. 

```sh
# Copy the ip addresses of the static and express dynamic servers
php /var/apache2/templates/config-template.php > /etc/apache2/sites-available/001-reverse-proxy.conf
```

To be sure that the script is executable on the *reverse-proxy server*, we configure the execution rights on the script : 

```shell
chmod 755 apache2-foreground
```



At the same level as the *Dockerfile*, we create a `templates` folder and inside a PHP file ` config-template.php`. This file will allow to retrieve the environment variables passed as parameters during the `docker run` command and to insert them in the configuration of the reverse proxy. It is this configuration that will be copied into the container using the `apache2-foreground` script that we created just before. 

```php
<?php
	$dynamic_app = getenv('DYNAMIC_APP');
	$static_app  = getenv('STATIC_APP');
?>

<VirtualHost *:80>
    ServerName demo.res.ch
	
    ProxyPass '/api/animals/' 'http://<?php print "$dynamic_app"?>/'
    ProxyPassReverse '/api/animals/' 'http://<?php print "$dynamic_app"?>/'

    ProxyPass '/' 'http://<?php print "$static_app"?>/'
    ProxyPassReverse '/' '<?php print "$static_app"?>/'
</VirtualHost>
```



It remains to modify the *Dockerfile* to integrate our new files into the container during the _run_ of the image: 

* We copy the script `apache2-foreground` in the ` /usr/local/bin` folder of the container. 
* We copy the `templates` folder containing the PHP file ` config-template.php` in the `/var/apache2/templates` folder of the container.

> **Warning**: It is important to note that the `apache2-foreground` script must be in UNIX format to run correctly on Linux. The problem is that using it on Windows will cause formatting problems and make the script potentially non-executable. It is possible to resolve this problem manually by rewriting or copying the script into a new file once in Windows. 
>
> However, we have chosen to perform this formatting automatically using the _dos2unix_ tool which allows it to be done. This tool is therefore downloaded when the Dockerfile is launched and the script converted. 

```dockerfile
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

# Install required modules
RUN a2enmod proxy proxy_http

# Active virtual hosts
RUN a2ensite 000-* 001-*
```



#### Tests

The goal here is to test that our reverse proxy manages IP addresses dynamically. For this, we run several static servers of the `apache_php` image and several dynamic express servers of the ` express_student` image, only a static server and a dynamic express server have a name with the `--name` flag, they are the servers we are going to use with our _reverse proxy_. 

```sh
docker run -d res/apache_php
docker run -d res/apache_php
docker run -d --name apache_static res/apache_php

docker run -d res/express_student
docker run -d res/express_student
docker run -d --name express_student res/express_student
```



Once launched, we retrieve their respective IP addresses with `docker inspect` .

```sh
docker inspect apache_static | grep -i ipaddr
docker inspect express_student | grep -i ipaddr
```



We can now run the _reverse proxy_ of the `apache_rp` image by indicating the IP addresses of our static and dynamic server with the ` -e` flag and our 2 environment variables `DYNAMIC_APP` and ` STATIC_APP`. 

In this command, the 2 addresses `x.x.x.x` and` y.y.y.y` are to be replaced by the IP addresses of our 2 servers retrieved just before. 

```sh
docker run -d -e STATIC_APP=x.x.x.x:80 -e DYNAMIC_APP=y.y.y.y:3000 --name apache_rp -p 8080:80 res/apache_rp
```



We can therefore verify that the _reverse proxy_ is indeed using our 2 servers by accessing the home page of our site at the address `http://demo.res.ch:8080/`.

The behavior of the _reverse proxy_ should be similar to the previous steps. The website is displayed and dynamic content fetched correctly. 

![S5-homepage-01](media/S5-homepage-01.PNG)



The solution described above is functional, but the recovery of the IP addresses of the containers and the launch of the _reverse proxy_ are not optimal. You have to execute these 3 commands each time, which can be redundant. We therefore decided to implement a `run-multi-containers` script which groups these actions and executes them automatically. 

The script : 

* Start a static server of the `apache_php` image and a dynamic server of the` express_student` image.
* Retrieve the IP addresses of these 2 containers with the `docker inspect` command and store them in 2 variables. 
* Run the _reverse proxy_ of the `apache_rp` image using the 2 variables above.

>**Warning**: Before running this script, make sure that no other container with the name `apache_php` or ` express_student` is present, if this is the case, it is necessary to delete them with `docker rm 'nomImage' `. 

```sh
#!/bin/bash
docker run -d --name apache_static res/apache_php
docker run -d --name express_student res/express_student

#Use to get ip address from apache static server automatically
ip_static=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' apache_static)

#Use to get ip address from express dynamic server automatically
ip_dynamic=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' express_student)

#Run reverse proxy server with ip addresses from static server and express dynamic server
docker run -d -e STATIC_APP=$ip_static:80 -e DYNAMIC_APP=$ip_dynamic:3000 --name apache_rp -p 8080:80 res/apache_rp
```

