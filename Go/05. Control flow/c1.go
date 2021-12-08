package main

import "fmt"

func main() {

	for i := 0; i <= 5; i++ {
		fmt.Println(i)
	}

	for i := 0; i <= 5; i++ {
		for j := 0; j < 3; j++ {
			fmt.Printf("%d - %d \n", i, j)
		}
	}

	//use for only with condition
	x := 1
	for x < 3 {
		fmt.Println(x)
		x++
	}

	//infinite for
	x = 1
	for {
		if x == 3 {
			break
		}
		fmt.Println(x)
		x++
	}

	//print only even numbers
	x = 0
	for {
		x++
		if x == 9 {
			break
		}
		if x%2 != 0 {
			continue
		}
		fmt.Println(x)
	}

	//show number and string representation
	for i := 33; i < 91; i++ {
		fmt.Printf("Number %d and string %s - ", i, string(i))
	}

	//using if
	for i := 0; i < 3; i++ {
		if i == 0 {
			fmt.Println(i)
		} else if i == 1 {
			fmt.Println(i)
		} else {
			fmt.Println("not 0 or 1")
		}
	}

	//using switch
	x = 4
	switch x {
	case 1:
		fmt.Println("It is 1")
	case 2:
		fmt.Println("It is 2")
	case 3:
		fmt.Println("It is 3")
	default:
		fmt.Println("It is none of the above")
	}
}
