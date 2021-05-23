// Execute callback function() when JQuery is loaded
$(function(){
  
    function loadAnimals(){
            
            // SEND HTTP GET request to /api/animals/
            $.getJSON("/api/animals/", function(animals){
                    var message = "Nobody is here"; 
                    if(animals.length > 0){
                            message = animals[0].Name;
                    }
                    //Replace html tag with class="skills" and insert the message
                    $(".skills").text(message);
            });
    };
    loadAnimals();
    //Execute loadAnimals every 2 seconds
    setInterval(loadAnimals, 2000);
});
