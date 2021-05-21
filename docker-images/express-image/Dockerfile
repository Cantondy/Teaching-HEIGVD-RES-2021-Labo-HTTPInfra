# Image node 4.4
FROM node:14.16.1

RUN apt-get update && \
    apt-get install -y vim

# Copy the content of src into /opt/app
COPY src /opt/app

# Command to be executed when running a container
CMD ["node", "/opt/app/index.js"]
