#!/bin/bash

#Use to get ip address from apache static server automatically
ip_static=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' apache_static)

#Use to get ip address from express dynamic server automatically
ip_dynamic=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' express_student)

#Run reverse proxy server with ip addresses from static server and express dynamic server
docker run -d -e STATIC_APP=$ip_static:80 -e DYNAMIC_APP=$ip_dynamic:3000 --name apache_rp -p 8080:80 res/apache_rp
