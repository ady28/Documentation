//npm install express
//npm install ejs
//npm install body-parser
//to test the requests I use VS Code extension: REST Client which uses file.http as a file where i can store requests

var express = require("express")
var bodyParser = require("body-parser")
var app = express()
app.use(bodyParser.json())
app.set("view engine", "ejs")

app.get("/", function(req, res){
    res.render("home")
})
app.get("/bye", function(req, res){
    res.send("Bye")
})

app.get("/test/:text", function(req, res){
    var text = req.params.text
    res.send("You tried the " + text + " endpoint")
})

app.get("/test/:text/stuff/:id", function(req, res){
    var text = req.params.text
    var id = req.params.id
    res.send(`You tried the ${text} endpoint with an id of ${id}`)
})

app.get("/servers/:name", function(req, res){
    var name = req.params.name
    res.render("server", {srvName: name})
})

app.post("/servers", function(req, res){
    var srv = req.body
    console.log(req.body)
    res.send("Server " + srv.name)
})

//add a route that will get triggered when the url does not match any of the named routes
//it should be the last in the routes list
app.get("*", function(req, res){
    res.send("Default")
})

app.listen("3000", "localhost")