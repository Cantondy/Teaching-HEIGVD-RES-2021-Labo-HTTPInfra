### Step 3: Reverse proxy with apache (static configuration)

#### Purpose

In this third part of the lab we were asked to configure a reverse proxy so that we can specify which resource we want to access.



#### Implementation

We create a Dockerfile containing the following lines:

```dockerfile
FROM php:7.2-apache 

COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

- `RUN a2enmod proxy proxy_http` activate proxy and proxy-http modules

- `RUN a2ensite 000-* 001-*` allows to activate files starting with "000-..." and "001-...".

In the `conf/` folder we will find the configuration files of our reverse proxy, this folder will be copied in the directory `/etc/apache2` of our container.

The configuration of our reserve proxy can be found in the file `001-reverse-proxy.conf`

  ```php
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

```sh
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
