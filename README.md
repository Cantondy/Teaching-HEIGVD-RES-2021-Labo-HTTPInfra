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



### Dynamic HTTP server with express.js

#### Purpose

In this second part of the lab we were asked to create a node.js project, node is used in combination with the package express to be able to create easily an http server, everything will then be integrated into a docker container.

#### Implementation

The server is run on the localhost address of the machine running the index.js file, the server listens on port 3000. Our server uses the express packages for the http server and the chance package to create a list of animals returned in the form of a JSON string.The server can be stopped with the command ctrl-c. We then create a dockerfile containing the following lines:

```
FROM node:14.16.1

COPY src /opt/app

CMD ["node", "/opt/app/index.js"]
```

- `FROM node:14.16.1` : This first line allows to recover the image of node.js.
- `COPY src /opt/app` : Finally, we copy the contents of the local `src` folder into our docker at the location `/opt/app`. This folder will contain our project node.js.
- `CMD ["node", "/opt/app/index.js"]` : indicate the command to be executed when launching the container.

Exemple of our JSON result: `{"Name":"Jackal","Age":33,"Gender":"Male"}`

#### Tests

In the `docker-images/express-image` folder you will find everything necessary for the installation of our node server. We need to build our docker image, I have already configured for you a bash file **build-image.sh** with the command: `docker build -t res/express_student .` , doing so will run the configurations found in the DockerFile. Then you need to run the newly created container with the command :`docker run -p 'yourPort':3000 res/express_student` (or use the file **run-container.sh** which uses the port-mapping -p 9090:3000). Finally you can retrieve the json files at `localhost:'portUsedBefore'`, through a browser, postman, telnet (or whatever you prefer ( ͡° ͜ʖ ͡°) ).

#### Result using Postman

![step2_1](media/step2_1.png)



### Reverse proxy with apache (static configuration)

#### Purpose

In this third part of the lab we were asked to configure a reverse proxy so that we can specify which resource we want to access.

#### Implementation

We create a Dockerfile containing the following lines:

```
FROM php:7.2-apache 

COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

- `RUN a2enmod proxy proxy_http` activate proxy and proxy-http modules

- `RUN a2ensite 000-* 001-*` allows to activate files starting with "000-..." and "001-...".

In the `conf/` folder we will find the configuration files of our reverse proxy, this folder will be copied in the directory `/etc/apache2` of our container.

The configuration of our reserve proxy can be found in the file `001-reverse-proxy.conf`

  ```
  <VirtualHost *:80>
      ServerName demo.res.ch
      
      ProxyPass "/api/animals/" "http://172.17.0.3:3000/"
      ProxyPassReverse "/api/animals/" "http://172.17.0.3:3000/"
  
      ProxyPass "/" "http://172.17.0.2:80/"
      ProxyPassReverse "/" "http://172.17.0.2:80/"
      
  </VirtualHost>
  ```

  The server runs at the address **demo.res.ch** at port **80**, you will need to configure the local dns of your machine, on Unix systems you will just add this line `127.0.0.1 demo.res.ch` to the file `~/etc/hosts`.

  Next we find the routes to our two containers, we have determined that:

  - The node.js server for the animal list will need to run at address **172.17.0.3 :3000**

  - The apache server that hosts our site should run at the address **172.17.0.2 :80**

    **Please note:** you will need to run the apache server first and then the node server, you will also need to make sure that the addresses assigned by docker are the same, to do this we can check with the command `docker inspect "containerName" | grep -I ipaddress`.

  We could then access it with the paths **/api/animals/** and **/** .

#### Tests

In the `docker-images/apache-reverse-proxy` folder you will find everything necessary for the installation of our reverse proxy. We need to build our docker image, I have already configured for you a bash file **build-image.sh** with the command: `docker build -t res/apache_rp .` , doing so will run the configurations found in the DockerFile. Then you will need to run the containers in the following order:

```
docker run -d res/apache_php
docker run -d res/express_student
docker run -d -p 8080:80 res/apache_rp
```

I have already configured for you a bash file **run-multi-containers.sh** with the commands above.

Finally you can retrieve our website at `demo.res.ch:8080` and our json animals at `demo.res.ch:8080/api/animals`

#### Result

**Website:**

![step3_1](media/step3_1.png)

**JSON content:**

![step3_2](media/step3_2.png)



#### Infrastructure Diagram

![step3_3](media/step3_3.png)

