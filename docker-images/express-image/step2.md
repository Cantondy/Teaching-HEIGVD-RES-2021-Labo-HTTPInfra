##Introduction
In this second part of the lab we were asked to create a node.js project, node is used in combination with the package express to be able to create easily an http server, everything will then be integrated into a docker container.

##Configuration
The server is run on the localhost address of the machine running the index.js file, the server listens on port 3000.
Our server uses the express packages for the http server and the chance package to create a list of animals returned in the form of a JSON string.The server can be stopped with the command ctrl-c.

Exemple of JSON result: `{"Name":"Jackal","Age":33,"Gender":"Male"}`

##Demo
Clone the repository with the command `git clone https://github.com/Cantondy/Teaching-HEIGVD-RES-2021-Labo-HTTPInfra.git`, place your terminal in folder `docker-images/express-image`.
Now we need to build our docker image using the command: `docker build -t alessandro/express_student .`
(I have already configured for you a bash file **build-image.sh** with the command), doing so will run the configurations found in the DockerFile.
Then you need to run the newly created container with the command :
`docker run -p 'yourPort':3000 alessandro/express_student` (or use the file **run-container.sh** which uses the port-mapping -p 9090:3000)
Finally you can retrieve the json files at `localhost:'portUsedBefore'`, through a browser, postman, telnet (or whatever you prefer ( ͡° ͜ʖ ͡°)  ).

