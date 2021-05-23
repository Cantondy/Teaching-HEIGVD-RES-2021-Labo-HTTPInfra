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
