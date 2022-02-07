var user = prompt('What is your name?')
var age = prompt('What is your age?')

function stuff(u,a){

    var days=a*365

    if(days == 365)
    {
        alert(u+' is only 1 year old.')
    }
    else if(days >365 && days <=2000)
    {
        alert(u+' is still young.')
    }
    else
    {
        alert(u+' is '+days+' days old.')
    }
}

stuff(user,age)