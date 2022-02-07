//npm install request
var request = require("request")

request("https://v2.jokeapi.dev/joke/Any", function(err, res, body){
    if(err){
        console.log(err)
    }
    else if(res.statusCode ==200){
        var jsonBody = JSON.parse(body)
        console.log(jsonBody['type'])
    }
})