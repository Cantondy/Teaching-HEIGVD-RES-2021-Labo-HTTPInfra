### Management UI

#### Purpose

Now we want to be able to visualize our images and docker containers in a user-friendly graphical interface where we can perform different operations(list containers, start/stop containers, etc.) .

**Please note: **For this step we decided not to make a web app, which would have taken a long time, we chose to use portainer. Portainer is an open-source management UI for Docker that  allows you to manage containers, images, networks, and volumes from the web-based Portainer dashboard.

#### Implementation

To proceed with the installation of portainer, I have already prepared a bash file **run-portainer.sh** (inside the folder `portainer`) for you containing:

```sh
docker volume create portainer_data

docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

```

* `docker volume create portainer_data` : This command creates a volume on your disk that  Portainer will use to store your configuration. Without this volume, the configuration data will be stored in the container and lost each time the container is restarted.

* The next command will allow you to download and run the Portainer image and start up the Portainer Container

#### Tests

Once the installation procedure is complete, we can connect to the address [localhost:9000](http://localhost:9000/)

![managementUI_1](./media/managementUI_1.png)

You will be displayed this interface where you have to register by entering a **username** and **password**(Don't forget them, they will be required at the next access to portainer).

We will configure Portainer to connect to the local Docker environment.

![managementUI_2](./media/managementUI_2.PNG)

Choose the 'Local' environment and click 'Connect' button.

We would be transported to the Portainer homepage, where we can find your local docker server, you can click on "local" to see your dashboard.

![managementUI_3](./media/managementUI_3.PNG)

Once in the dashboard, there will be different options, such as managing containers, images, volumes, networks and much more.

![managementUI_4](./media/managementUI_4.PNG)

For container management just click on "container" to get the list of containers

![managementUI_5](./media/managementUI_5.PNG)

In this web interface we can see important information about the container, such as name, state, IP addresses, creation date,  port addresses etc.., in addition we would have available most of the basic functions of docker such as, run, start, stop, kill, exec and much more.

**Please note**: Portainer contains many other features that were not covered during this use case, the demo is for container management purposes only. Here a more detailed [documentation](https://documentation.portainer.io/) about portainer.

