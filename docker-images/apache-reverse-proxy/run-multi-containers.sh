#!/bin/bash
docker run -d res/apache_php
docker run -d res/express_student
docker run -d -p 8080:80 res/apache_rp
