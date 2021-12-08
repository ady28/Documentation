package main

import "fmt"

func main() {

	m := map[string]int{
		"James": 22,
		"Frank": 17,
		"Molly": 19,
	}
	fmt.Println(m)
	fmt.Println(m["Frank"])

	//add to map
	m["Todd"] = 54
	fmt.Println(m)

	//delete from map
	delete(m, "James")
	fmt.Println(m)

	v, ok := m["NotExisting"]
	fmt.Println(v, ok)

	//if ok is true print something
	if v, ok := m["Molly"]; ok {
		fmt.Println(v)
	}

}
