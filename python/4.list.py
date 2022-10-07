#!/usr/bin/env python3

states = ["Delaware","Pensylvania","California","Colorado"]

print(states[0])
print(states[-1])

#Change a value
states[0]="Utah"
print(states[0])

#Add itrms to list
states.append("Nebraska")
print(states[-1])

#slice a list
states2 = states[2:3]
print(states2)

#reverse a list
states3 = states[::-1]
print(states3)

#List of lists
cities = ["Bucuresti","Pitesti","Constanta"]
towns = ["Bragadiru","Corbeanca","Bradu","Rucar"]
establishments = [cities, towns]
print(establishments)

#Create a new list using list comprehention
l = [1,2,3,4,5]
newl = [n + 1 for n in l]
print(newl)

#list comprehention works also with strings
s = "Adi"
news = [st.capitalize() for st in s]
print(news)