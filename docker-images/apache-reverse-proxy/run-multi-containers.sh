#!/bin/bash
docker run -d cantondy/apache_php
docker run -d alessandro/express_student
docker run -d -p 8080:80 alessandro/apache_rp
