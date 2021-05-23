### Step 4: AJAX requests with JQuery

#### Purpose

In this fourth part of the workshop we were asked to make the content of our web page dynamic.



#### Implementation

In this step we added to the Dockerfiles:

```sh
RUN apt-get update && \
    apt-get install -y vim
```

These two lines allow us to install the [Vim](https://www.vim.org/) text editor every time we create a new container, in this way we could edit the files inside the containers.

We have created a Javascript file "animals.js" in `docker-images/apache-php-image/content/js`:

```javascript
$(function(){
    function loadAnimals(){
            $.getJSON("/api/animals/", function(animals){
                    var message = "Nobody is here"; 
                    if(animals.length > 0){
                            message = animals[0].Name;
                    }
                    $(".skills").text(message);
            });
    };
    loadAnimals();
    setInterval(loadAnimals, 2000);
});
```

This function will be executed when the JQuery library is loaded because is called used the variable $, it sends an Ajax request to fetch the JSON data provided by our node.js server which provides a list of animals in JSON format. It will then take the name of the first animal in the list and insert it inside the HTML tag that contains the **class="skills"**. The function will be repeated every 2 seconds.

Then we integrated it with what we did in the previous step by adding scripts to the initial page **index.html**

```html
<script src="https://code.jquery.com/jquery-3.6.0.js"></script>
<script src="js/animals.js"></script>
```

- The first line allows us to library [JQuery](https://jquery.com/)
- The second allows us to include the previously created animals.js file.

Once this is done we have obtained our dynamic site that we can find at the address **demo.res.ch:8080**



#### Tests

In this phase it will be necessary to rebuild the `res/apache_php` image in order to make the modifications made using `docker-images/apache-php-image/build-image.sh`. Go in the `docker-images/apache-reverse-proxy` folder you will find everything necessary for launch our dynamic website. Then you will need to run the containers in the following order:

```dockerfile
docker run -d res/apache_php
docker run -d res/express_student
docker run -d -p 8080:80 res/apache_rp
```

I have already configured for you a bash file **run-multi-containers.sh** with the commands above.

Finally you can retrieve our dynamic website at `demo.res.ch:8080` and our JSON animals at `demo.res.ch:8080/api/animals`



#### Result

![step4_1](media/step4_1.gif)
