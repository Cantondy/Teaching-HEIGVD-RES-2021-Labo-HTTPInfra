# Teaching-HEIGVD-RES-2021-Labo-HTTPInfra

###### Alessando Parrino & Dylan Canton

###### 23.05.2021

---

### Load balancing : multiple server nodes

#### Purpose

Implementation of a load balancing system in the event of a server failure. The load is then distributed over the other servers in the cluster so that the site remains accessible. 



#### Implementation

The apache documentation provides a module for load balancing : https://httpd.apache.org/docs/2.4/mod/mod_proxy_balancer.html



Its implementation requires : 

* the `proxy module` (already installed)
* `the proxy_balancer` module 
* And a module providing the load balancing algorithm. 

In our case, we have chosen the `lbmethod_byrequests` module which is based on the number of requests 



We first add the 2 modules `proxy_balancer` and ` lbmethod_byrequests` in the Dockerfile of the _reverse proxy_.

```dockerfile
RUN a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests
```



After that, we configure the load balancing clusters in the `config-template.php` file. Clusters are groupings of several servers. We are setting up 2 clusters here (between the <Proxy> tags) , one containing 2 static servers and the other 2 dynamic servers. We then modify the reverse proxy so that it calls these clusters rather than our servers directly. 

We are also adding a tool that allows the management of load balancing in the browser on the page http://demo.res.ch/balancer-manager.

```php
<Location /balancer-manager>
    SetHandler balancer-manager
</Location>
  
ProxyPass /balancer-manager !
```



```php
<?php
	$dynamic_app_1 = getenv('DYNAMIC_APP_1');
	$dynamic_app_2 = getenv('DYNAMIC_APP_2');
	$static_app_1  = getenv('STATIC_APP_1');
	$static_app_2  = getenv('STATIC_APP_2');
?>

<VirtualHost *:80>
    ServerName demo.res.ch
    
    <Location /balancer-manager>
      SetHandler balancer-manager
    </Location>
  
    ProxyPass /balancer-manager !
	
    <Proxy "balancer://dynamic_app_cluster">
    BalancerMember 'http://<?php print "$dynamic_app_1"?>'
    BalancerMember 'http://<?php print "$dynamic_app_2"?>'
    </Proxy>

    <Proxy "balancer://static_app_cluster">
    BalancerMember 'http://<?php print "$static_app_1"?>'
    BalancerMember 'http://<?php print "$static_app_2"?>'
    </Proxy>

    ProxyPass '/api/animals/' 'balancer://dynamic_app_cluster/'
    ProxyPassReverse '/api/animals/' 'balancer://dynamic_app_cluster/'

    ProxyPass '/' 'balancer://static_app_cluster/'
    ProxyPassReverse '/' 'balancer://static_app_cluster/'
</VirtualHost>
```



#### Tests

We launch 2 static servers and 2 dynamic express servers :

```sh
docker run -d --name apache_static_1 res/apache_php
docker run -d --name apache_static_2 res/apache_php
docker run -d --name express_student_1 res/express_student
docker run -d --name express_student_2 res/express_student
```



We then get the ip addresses with the `docker inspect myContainerName | grep -i ipaddr` command.



We launch the reverse proxy with the IP addresses of the 4 servers launched previously  : 

```sh
docker run -d -e STATIC_APP_1=x.x.x.x:80 -e STATIC_APP_2=x.x.x.x:80 -e DYNAMIC_APP_1=y.y.y.y:3000 -e DYNAMIC_APP_2=y.y.y.y:3000 --name apache_rp -p 8080:80 res/apache_rp
```



We make sure that the site is accessible and works correctly, we will then stop a static server and a dynamic express server to use load balancing.

```sh
docker kill apache_static_2
docker kill express_student_1
```



We check that the site is still working.

![LB-siteUp](media/LB-siteUp.PNG)



We can see the load balancing status on the page http://demo.res.ch/balancer-manager. Since 2 servers are down, load balancing has distributed the load on the other server of each cluster. 

![LB-manager](media/LB-manager.PNG)



As in step 5, we want to automate the launch of the servers. We therefore create a `run-multi-containers-loadBalancing` script using the` run-multi-containers` script from step 5 as a base. 

```sh
#!/bin/bash
docker run -d --name apache_static_1 res/apache_php
docker run -d --name apache_static_2 res/apache_php
docker run -d --name express_student_1 res/express_student
docker run -d --name express_student_2 res/express_student

#Use to get ip address from apache static servers automatically
ip_static_1=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' apache_static_1)

ip_static_2=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' apache_static_2)

#Use to get ip address from express dynamic servers automatically
ip_dynamic_1=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' express_student_1)

ip_dynamic_2=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' express_student_2)

#Run reverse proxy server with ip addresses from static server and express dynamic server
docker run -d -e STATIC_APP_1=$ip_static_1:80 -e STATIC_APP_2=$ip_static_2:80 -e DYNAMIC_APP_1=$ip_dynamic_1:3000 -e DYNAMIC_APP_2=$ip_dynamic_2:3000 --name apache_rp -p 8080:80 res/apache_rp
```

