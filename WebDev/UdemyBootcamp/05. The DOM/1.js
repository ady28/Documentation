var h1id = document.querySelector("#title")
h1id.addEventListener("mouseover", function(){
    h1id.style.color="red"
    h1id.textContent="Changed text"
})
h1id.addEventListener("mouseout", function(){
    h1id.style.color="blue"
    h1id.textContent="Changed text"
})
h1id.addEventListener("click", function(){
    h1id.style.color="black"
    h1id.textContent="The DOM"
})

var h2s=document.querySelectorAll(".h2text")
h2s.forEach(function(h2) {
    h2.style.color="blue"    
});

var h3s=document.querySelectorAll("h3")
h3s.forEach(function(h3) {
    h3.style.color="green"    
});

var testtext=document.querySelector("#testtext")
/*besides add there are also remove and toggle*/
testtext.classList.add("testclass")
