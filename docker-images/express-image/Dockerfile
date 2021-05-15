# Image node 4.4
FROM node:14.16.1
#MAINTAINER Parrino Alessandro <alessandro.parrino@heig-vd.ch>

EXPOSE 9090

# Copy the content of src into /opt/app
COPY src /opt/app

# Command to be executed when running a container
CMD ["node", "/opt/app/index.js"]