package main

import "fmt"

type person struct {
	first string
	last  string
	age   int
}

//embedded struct
type agent struct {
	person
	license bool
}

func main() {

	p1 := person{
		first: "Adi",
		last:  "Du",
		age:   31,
	}
	p2 := person{
		first: "Ady",
		last:  "Dum",
		age:   23,
	}

	fmt.Println(p1)
	fmt.Println(p2)
	fmt.Println("First name is:", p1.first)

	a1 := agent{
		person:  p1,
		license: true,
	}
	fmt.Println(a1)
	a2 := agent{
		person: person{
			first: "Smith",
			last:  "Agent",
			age:   100,
		},
		license: false,
	}
	fmt.Println(a2)
	fmt.Println(a2.first, a2.license)

	//Anonymous struct
	p3 := struct {
		first string
		last  string
		age   int
	}{
		first: "Smith1",
		last:  "Agent1",
		age:   1001,
	}
	fmt.Println(p3)

}
