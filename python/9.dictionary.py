#!/usr/bin/env python3

test_dict = {
    "Bug":"Just a bug",
    "Error":"Just an error",
}

print(test_dict["Bug"])

#Add item
test_dict["Warning"]="Just a warning"

print(test_dict)

#empty dictionary (also used to wipe a dictionary)
empty_dict = {}

for item in test_dict:
    print(test_dict[item])

#a nested dict
nested_dict = {
    "Cities" : ["Paris","Berlin","Bucharest"],
    "Address" : {
        "City" : "Paris",
        "Street" : "Champagne rue"
    },
}
print(nested_dict)
print(nested_dict["Cities"][1])

#list of dictionaries
list_dict = [
    {
        "Test1" : "T1",
        "Test2" : "T2",
    },
    {
        "Test3" : "T3",
        "Test4" : "T4",
    }
]
print(list_dict)