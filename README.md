# Teaching-HEIGVD-RES-2021-Labo-HTTPInfra
###### Alessando Parrino & Dylan Canton

###### 17.05.2021

---

### Static HTTP server with apache httpd

#### Purpose

This step allows you to set up an apache httpd server in a docker. A web template is also set up in order to have a coherent and clean rendering. 



#### Implementation

First of all we download the apache server docker image on *dockerhub*. It was chosen here to take an image taking into account a PHP server, in order to increase the scalability over time and the possibilities offered. The chosen image is therefore the official image of PHP with apache HTTPD server at this address: https://hub.docker.com/_/php/ 

We then create a dockerfile containing the following lines: 

```
FROM php:7.2-apache
MAINTAINER Dylan Canton <dylan.canton@heig-vd.ch>

COPY content/ /var/www/html/
```

* `FROM php:7.2-apache` : This first line allows to recover the image of PHP with apache server in version 7.2. 
* `MAINTAINER Dylan Canton <dylan.canton@heig-vd.ch>` : This line is indicative, it simply describes the author of this dockerfile. 
* `COPY content/ /var/www/html/` : Finally, we copy the contents of the local `content` folder into our docker at the location `/var/www/html`. This folder will contain our static website to launch in the docker container. 



To provide us with a theme for the static website, there is a wide variety of sites offering free templates. We chose to take one from this site: https://www.free-css.com/free-css-templates and modify it to keep only the essential, a home page. 

The files of this web template are therefore put in our local `content ` folder so that they are copied into the docker when the container is launched. 

Then we create 2 scripts for the build of the image and the launch in order to facilitate the use of docker. The first script `build-image.sh` allows to build the image  

```
#!/bin/bash

# Build the Docker image
docker build --tag cantondy/apache_php .
```



The second script `run-container.sh` allows you to launch the container, note here that the option ` -p 9090: 80` allows you to do a port mapping. We redirect port **9090** of our local machine to port **80** of the docker in order to access the apache server on our browser (port 80 being provided for the HTTP protocol). 

```
#!/bin/bash

# Run docker image and do port mapping
docker run -p 9090:80 cantondy/apache_php
```



#### Tests

The `content` folder, the dockerfile and the 2 scripts for building and launching the image are put in a single folder. 

Then we build the image by running the `build.image.sh` script 

```shell
./build-image.sh
```

And we launch the docker with the second script `run-container.sh` 

```shell
./run-container.sh
```

The docker is now running, we try to access our static website from our local machine by typing the address `localhost: 9090` in our browser. We can see here that the site is accessible and displays the template that we have set up : 

![step1_1](media/step1_1.PNG)



