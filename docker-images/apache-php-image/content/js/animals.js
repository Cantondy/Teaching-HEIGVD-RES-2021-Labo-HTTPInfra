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
