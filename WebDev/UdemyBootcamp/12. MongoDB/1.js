//npm install mongoose
var mongoose = require("mongoose")
mongoose.connect("mongodb://localhost/testdb")

var schema = new mongoose.Schema({
    name: String,
    role: String,
    os: String
},
    //if this is not set to false we will get a __v property
    {versionKey: false}
)

var server = mongoose.model("server", schema)
//we can also put the model and schema part in a separate file
//in that file we need to require mongoose
//at the end we use module.exports = server to export the server model
//we then require the file in the main app var server=require...

/*var s1 = new server({
    name: "SRV03",
    role: "DC",
    os: "Windows Server 2019"
})
s1.save(function(err, ret){
    if(err){
        console.log("There was an error saving server")
    }
    else {
        console.log("New server saved:")
        console.log(ret)
    }
})*/

server.find({name: "SRV01"}, function(err, ret){
    if(err){
        console.log("There was an error getting servers")
    }
    else{
        console.log(ret[0].name)
    }
})