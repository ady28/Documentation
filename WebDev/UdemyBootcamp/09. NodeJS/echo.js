function echo(t, n) {
    for(var i = 0; i < n; i++){
        console.log(t)
    }
}

echo("Test", 3)
echo("Easy", 1)

function average(scores){
    var sum = 0
    for(var i=0; i < scores.length; i++){
        sum+=scores[i]
    }

    console.log(Math.round(sum/scores.length))
}

var s1 = [10, 20, 30]
average(s1)