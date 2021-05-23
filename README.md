### Step 2: Dynamic HTTP server with express.js

#### Purpose

In this second part of the lab we were asked to create a node.js project, node is used in combination with the package express to be able to create easily an http server, everything will then be integrated into a docker container.



#### Implementation

The server is run on the localhost address of the machine running the index.js file, the server listens on port 3000. Our server uses the express packages for the http server and the chance package to create a list of animals returned in the form of a JSON string.The server can be stopped with the command ctrl-c. We then create a dockerfile containing the following lines:

```dockerfile
FROM node:14.16.1

COPY src /opt/app

CMD ["node", "/opt/app/index.js"]
```

- `FROM node:14.16.1` : This first line allows to recover the image of node.js.
- `COPY src /opt/app` : Finally, we copy the contents of the local `src` folder into our docker at the location `/opt/app`. This folder will contain our project node.js.
- `CMD ["node", "/opt/app/index.js"]` : indicate the command to be executed when launching the container.

Exemple of our JSON result: `{"Name":"Jackal","Age":33,"Gender":"Male"}`



#### Tests

In the `docker-images/express-image` folder you will find everything necessary for the installation of our node server. We need to build our docker image, I have already configured for you a bash file **build-image.sh** with the command: `docker build -t res/express_student .` , doing so will run the configurations found in the DockerFile. Then you need to run the newly created container with the command :`docker run -p 'yourPort':3000 res/express_student` (or use the file **run-container.sh** which uses the port-mapping -p 9090:3000). Finally you can retrieve the json files at `localhost:'portUsedBefore'`, through a browser, postman, telnet (or whatever you prefer ( ͡° ͜ʖ ͡°) ).



#### Result using Postman

![step2_1](media/step2_1.png)
