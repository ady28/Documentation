//install packages: npm install @faker-js/faker

//var faker = require("@faker-js/faker")
var { faker } = require('@faker-js/faker');
var product, price

for(var i =0; i < 10; i++){
    product = faker.commerce.productName()
    price = faker.commerce.price()  
    console.log(product + " - $" + price)
}