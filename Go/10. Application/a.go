package main

import (
	"encoding/json"
	"fmt"
	"sort"
)

//for working with the json Marshal method you need upper case parameters in the struct
type person struct {
	First string
	Last  string
	Age   int
}

//create a function that prints people
func (p person) String() string {
	return fmt.Sprintf("%s %s: %d", p.First, p.Last, p.Age)
}

//by age implements sort.Interface for []person based on age
type byAge []person

//if a type has these 3 methods then it implements the interface from the sort package
func (a byAge) Len() int {
	return len(a)
}
func (a byAge) Swap(i, j int) {
	a[i], a[j] = a[j], a[i]
}
func (a byAge) Less(i, j int) bool {
	return a[i].Age < a[j].Age
}

func main() {

	//string representing a json object
	//if it was an array enclose everything in []
	s := `{"First":"Ady","Last":"Dumy","Age":32}`
	bs := []byte(s)

	p1 := person{
		First: "Adi",
		Last:  "Du",
		Age:   31,
	}
	p2 := person{
		First: "Ady",
		Last:  "Dum",
		Age:   23,
	}

	people := []person{p1, p2}

	fmt.Println(people)

	//transform the slice of person to json
	sb, err := json.Marshal(people)
	if err != nil {
		fmt.Println("Error marshaling data:", err)
	}
	fmt.Println(string(sb))

	//declare a person variable
	//if the json to be converted was an array then use []person{}
	people2 := person{}

	err = json.Unmarshal(bs, &people2)
	if err != nil {
		fmt.Println("Error unmarshaling data:", err)
	}
	fmt.Println(people2)

	//try sorting
	xi := []int{5, 9, 1, 10, 3, 23, 12}
	xs := []string{"Viespe", "adi", "Adi", "Clau", "clau"}

	sort.Ints(xi)
	fmt.Println(xi)

	sort.Strings(xs)
	fmt.Println(xs)

	//sort people by age
	sort.Sort(byAge(people))
	fmt.Println(people)

}
