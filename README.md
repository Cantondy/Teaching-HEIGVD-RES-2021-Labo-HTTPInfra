# Teaching-HEIGVD-RES-2021-Labo-HTTPInfra

###### Alessando Parrino & Dylan Canton

###### 23.05.2021

---

### Load balancing : Round-robin vs Sticky sessions

#### Purpose

The goal here is to show that the load balancer uses the _round-robin_ to distribute requests to dynamic servers as well as the implementation of _sticky sessions_ for requests to static servers. 

The _round-robin_ is a scheduling algorithm allowing to distribute the working time between the different systems. The requests sent will be distributed among the various servers available according to the scheduling algorithm. 

Setting up _sticky-sessions_ makes it possible to keep a session open for several exchanges of requests between a client and the same server. 



#### Implementation

The implementation of the _sticky sessions_ is indicated on the page concerning the load balancing_ of apache : https://httpd.apache.org/docs/2.4/mod/mod_proxy_balancer.html



The method chosen here for the _sticky sessions_ is the use of *cookies*. We add the `headers` module in the _Dockerfile_ of the reverse proxy which allows us to implement the *cookies* system. 

```
RUN a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers
```



The `config-template.php` file is modified in order to add a cookie.

```php
Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED
```



We must also configure a route for each member of the static server cluster.

```php
BalancerMember 'http://<?php print "$dynamic_app_X"?>' route=X
```



Finally, we link the session to the cookie created previously.

```php
ProxySet stickysession=ROUTEID
```



Here is the `config-template.php` file after configuring cookies for _sticky sessions_ :

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
	
    Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED
    
    <Proxy "balancer://dynamic_app_cluster">
    BalancerMember 'http://<?php print "$dynamic_app_1"?>'
    BalancerMember 'http://<?php print "$dynamic_app_2"?>'
    </Proxy>

    <Proxy "balancer://static_app_cluster">
    BalancerMember 'http://<?php print "$static_app_1"?>' route=1
    BalancerMember 'http://<?php print "$static_app_2"?>' route=2
    ProxySet stickysession=ROUTEID
    </Proxy>

    ProxyPass '/api/animals/' 'balancer://dynamic_app_cluster/'
    ProxyPassReverse '/api/animals/' 'balancer://dynamic_app_cluster/'

    ProxyPass '/' 'balancer://static_app_cluster/'
    ProxyPassReverse '/' 'balancer://static_app_cluster/'
</VirtualHost>
```



#### Tests

Having added a module in the _Dockerfile_ of the reverse proxy, we must first rebuild the `res/apache_rp` image. 

We then launch the _load balancing_ infrastructure, manually or with the `run-multi-containers-loadBalancing` script as in the _Load balancing step: multiple server nodes_.

You can access the load balancing management page at the address http://demo.res.ch:8080/balancer-manager.



**1. Round-Robin**

We go to the cluster management page at the address http://demo.res.ch:8080/balancer-manager. We then examine the `Elected` field of our dynamic servers. 

This counter increases for each server alternately each time we refresh a page of the site or open a new one. We also observe that as soon as one of the 2 servers is down, only the counter of the functioning server increases linearly. 

![LB-roundrobin](media/LB-roundrobin.PNG)

It should be noted that the `balance-manager` page must be refreshed each time for the changes to be visible. This behavior of the counter then allows us to check that the _Round-robin_ is working correctly. 



**2. Sticky sessions**

To test the _sticky sessions_, we modify the site page (_index.html_) of the 2nd image of the static server (modification of the title) in order to differentiate the 2 images of the static server. 

We then access the page in the browser at the address http://demo.res.ch:8080/, we arrive on this page :  

![LB-SS-homepage1](media/LB-SS-homepage1.PNG)



We will now delete the cookies from our browser and reload the page. We can therefore see that we are this time on the page of the other static server. 

![LB-SS-homepage2](media/LB-SS-homepage2.PNG)



Using the cookie, we communicated with the same static server even during a page refresh. But as soon as the cookie is deleted, the client is no longer "*linked*" to the first server and can therefore access the second. 

A final check consists of going to the _load balancing_ management page at the address http://demo.res.ch:8080/balancer-manager. 

We see in the field `StickySession` contains the parameter` ROUTEID` defined previously in our `config-template.php` file. Our 2 static sites also have their respective route in the `Route` field.

![LB-stickySession](media/LB-stickySession.PNG)
