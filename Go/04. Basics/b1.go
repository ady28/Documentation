package main

import (
	"fmt"
	"runtime"
)

//declare a variable outside of a function
var a = 21

//declare global variable with type
var b int

//declare global variable with type and value
var c string = "Testing"

//using ` we can set the exact string value
var d string = `John said "Testing"`

//declare a boolean
var i bool

//create a type
type mytype int

var e mytype = 89

//declare constants
const ca = 20
const cb = 1.2

//or
const (
	cd = "Test constant"
	ce = true
)

//using iota to autoincrement values
const (
	cf = iota
	cg
	ch
)

func main() {
	//println returns 2 values: number of characters and error
	//we can capture the number of arguments but ignore the error like this:
	n, _ := fmt.Println("Hello, World!")
	fmt.Println(n)

	//declare and assign a value to a variable
	x := 10
	fmt.Println(x)
	//with the variable declared, just assign another value
	x = 11
	fmt.Println(x)

	fmt.Println(a)
	fmt.Printf("%T\n", a)
	fmt.Printf("%b\n", a)
	fmt.Printf("%x\n", a)
	fmt.Printf("%#x\n", a)

	fmt.Println(c)
	fmt.Printf("%T\n", c)

	fmt.Println(d)

	fmt.Println(e)
	fmt.Printf("%T\n", e)

	//convert a type to another type
	b = int(e)
	fmt.Println(b)
	fmt.Printf("%T\n", b)

	f := 42
	g := "James Bond"
	h := true
	fmt.Println(f, g, h)

	s := fmt.Sprintf("%d %s %t", f, g, h)
	fmt.Println(s)

	fmt.Println(e)
	fmt.Printf("%T\n", e)

	fmt.Println(i)

	fmt.Println(x == a)

	//use GO environment variables
	fmt.Println(runtime.GOOS)

	//convert string to a slice of bytes
	bs := []byte(d)
	fmt.Println(bs)
	fmt.Printf("%T\n", bs)

	//show characters of a string with the UTF8 values
	for it := 0; it < len(d); it++ {
		fmt.Printf("%#U ", d[it])
	}
	fmt.Println("")
	//print the index and the numerical value of the character at that index in the string
	for it, v := range d {
		fmt.Println(it, v)
		fmt.Printf("At index %d we have character %#x \n", it, v)
	}

	fmt.Println(ch)

	//shifting bits
	n1 := 2
	fmt.Printf("%d\t%b\n", n1, n1)
	n2 := n1 << 1
	fmt.Printf("%d\t%b\n", n2, n2)

}
