var numberOfSquares
var colors
var pickedColor

var squares=document.querySelectorAll(".square")
var colorDisplay=document.querySelector("#colorDisplay")
var messageDisplay=document.querySelector("#message")
var h1=document.querySelector("h1")
var resetButton=document.querySelector("#reset")
var modeButtons=document.querySelectorAll(".mode")

init()

function init()
{
    numberOfSquares = 6
    setupModeButtons()
    setupSquares()
    reset()
}

function setupModeButtons()
{
    for(var i=0; i < modeButtons.length; i++)
    {
        resetButton.addEventListener("click", reset)
        modeButtons[i].addEventListener("click", function(){
            modeButtons[0].classList.remove("selected")
            modeButtons[1].classList.remove("selected")
            modeButtons[2].classList.remove("selected")
            this.classList.add("selected")
            if(this.textContent == "Easy")
            {
                numberOfSquares = 3
            }
            else if(this.textContent == "Normal")
            {
                numberOfSquares = 6
            }
            else if(this.textContent == "Hard")
            {
                numberOfSquares = 9
            }

            reset()
        })
    }
}

function setupSquares()
{
    squares.forEach(function(square){
        square.addEventListener("click",function(){
            var clickedColor=this.style.backgroundColor
            if(clickedColor == pickedColor)
            {
                messageDisplay.textContent="Correct!"
                changeColors(pickedColor)
            }
            else
            {
                this.style.backgroundColor = "#232323"
                messageDisplay.textContent="Try again!"
            }
        })
    })
}

function changeColors(color){
    squares.forEach(function(square){
        square.style.backgroundColor=color
    })
    h1.style.backgroundColor=color
}

function pickColor(){
    var number = Math.floor(Math.random() * colors.length)
    return colors[number]
}

function generateRandomColors(num)
{
    var arr = []

    for(var i=0; i < num; i++)
    {
        arr.push(randomColor())
    }

    return arr
}
function randomColor()
{
   var r = Math.floor(Math.random() * 256)
   var g = Math.floor(Math.random() * 256)
   var b = Math.floor(Math.random() * 256)

   return "rgb(" + r + ", " + g + ", " + b + ")"
}

function reset()
{
    colors=generateRandomColors(numberOfSquares)
    pickedColor=pickColor()
    colorDisplay.textContent=pickedColor

    var i=0
    squares.forEach(function(square) {
        if(colors[i])
        {
            square.style.backgroundColor=colors[i]
            square.style.display="block"
        }
        else
        {
            square.style.display="none"
        }
        i++
    })

    h1.style.backgroundColor="steelblue"
    messageDisplay.textContent=""
}