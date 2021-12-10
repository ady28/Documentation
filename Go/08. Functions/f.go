package main

import "fmt"

//a function would look like
//func (r receiver) identifier(parameter(s)) (return(s)) {...}

type person struct {
	first string
	last  string
	age   int
}
type agent struct {
	person
	license bool
}

//create a method attached to the agent type
func (a agent) speak() {
	fmt.Println("My name is:", a.first, a.last, "and i am an agent")
}
func (p person) speak() {
	fmt.Println("My name is:", p.first, p.last, "and i am a person")
}

//create an interface
//any type that has the method speak() associated is of type human also
type human interface {
	speak()
}

func hmn(h human) {
	switch h.(type) {

	case person:
		fmt.Println("I am a human person", h.(person).first)
	case agent:
		fmt.Println("I am a human agent", h.(agent).first)
	}
}

func main() {

	sayHi1()
	sayHi2("Adi")
	s1 := sayHi3("Ady")
	fmt.Println(s1)
	//defer a function to be executed at the end of the current function
	defer sayHi2("End")
	s2, b := sayHi4("Adi", "Dumitras")
	fmt.Println(s2, b)

	sum := numbers(1, 2, 3, 4, 5, 6)
	fmt.Println(sum)

	no1 := []int{4, 5, 1, 2}
	sum = numbers(no1...)
	fmt.Println(sum)

	//we can also pass no arguments
	sum = numbers()
	fmt.Println(sum)

	//use a callback for numbers
	sum = even(numbers, no1...)
	fmt.Println(sum)

	a1 := agent{
		person: person{
			first: "Smith",
			last:  "Agent",
			age:   100,
		},
		license: false,
	}
	p1 := person{
		first: "Adi",
		last:  "Du",
		age:   31,
	}

	a1.speak()
	p1.speak()
	hmn(a1)
	hmn(p1)

	//anonymous function
	func(x int) {
		fmt.Println("Hello from Anonymous! We are", x, "years old!")
	}(23)

	//create a variable that is actually an anonymous function
	f := func(x int) {
		fmt.Println("Hello from Anonymous! We are", x, "years old!")
	}
	f(24)

	fr := fRet()
	fmt.Printf("%T\n", fr)
	//now fr is a func which can be executed
	frr := fr()
	fmt.Println(frr)
}

func sayHi1() {
	fmt.Println("Hi!")
}
func sayHi2(s string) {
	fmt.Println("Hello,", s)
}
func sayHi3(s string) string {
	return fmt.Sprint("Hello Mr. ", s, "!")
}
func sayHi4(s1 string, s2 string) (string, bool) {
	return fmt.Sprint("Hello Mr. ", s1, " ", s2, "!"), true
}

//get multiple parameters and store tham in a slice
func numbers(n ...int) int {
	fmt.Println(n)
	fmt.Printf("%T\n", n)

	//calculate the sum
	sum := 0
	for _, v := range n {
		sum += v
	}
	fmt.Println("The sum is", sum)
	return sum
}

//create a callback function
func even(f func(n ...int) int, vi ...int) int {
	var yi []int
	for _, v := range vi {
		if v%2 == 0 {
			yi = append(yi, v)
		}
	}
	//call the f function on the even numbers
	return f(yi...)
}

//return a function that returns an int
func fRet() func() int {
	fr := func() int {
		return 123
	}
	return fr
}
