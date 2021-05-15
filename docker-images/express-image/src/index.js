//Import 'chance' module
const Chance = require('chance');
const express = require('express');


//HTTP with express-generator
const app = express();
const port = 3000;
var chance = new Chance();

app.get('/', (req, res) => {
  res.send(generateAnimals());
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
})

process.on('SIGINT', function() {
  console.log("Exit");
  process.exit();
});

function generateAnimals() {
  var numberOfAnimals = chance.integer({
    min: 0,
    max: 10
  });
  var animals = []
  for (var i = 0; i < numberOfAnimals; ++i) {
    //Animals characteristics
    var name = chance.animal();
    var age = chance.integer({
      min: 0,
      max: 50
    });
    var gender = chance.gender();
    //Create Json
    animals.push({
      Name: name,
      Age: age,
      Gender: gender
    });
  }
  console.log(animals);
  return animals;

}