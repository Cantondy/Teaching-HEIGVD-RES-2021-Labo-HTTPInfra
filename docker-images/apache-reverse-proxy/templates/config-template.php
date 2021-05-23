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
