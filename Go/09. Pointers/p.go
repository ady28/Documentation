package main

import "fmt"

func main() {

	a := 43
	fmt.Println(a)
	//print the address of a
	fmt.Println(&a)
	//show the type of &a which is a pointer to an int
	fmt.Printf("%T\n", &a)

	//assign b the address behind a
	b := &a
	//show what is in that memory location
	fmt.Println(*b)
	fmt.Println(*&a)

	//change the value at that address
	*b = 12
	fmt.Println(a)

	y := 1
	test(&y)
	fmt.Println(y)
}

func test(x *int) {
	fmt.Println(*x)
	*x = 21
	fmt.Println(*x)
}
