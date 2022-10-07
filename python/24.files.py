#!/usr/bin/env python3

import csv,pandas

file = open("24.test.txt")
content = file.read()
print(content)
file.close()

#alternative method to open and close
with open("24.test.txt") as file:
    content = file.read()
    print(content)

file = open(file="24.test.txt", mode="a")
file.write("Test write to file")
file.close()

#In write mode it always overwrites what is already in the file and if file does not exist, it creates it
file = open(file="24.test1.txt", mode="a")
file.write("Test write to file")
file.close()

#csv
with open("24.testcsv.csv") as file:
    content = csv.reader(file)
    ages = []
    for row in content:
        if(row[1] != "age"):
            ages.append(int(row[1]))
    print(ages)

#to work more easier with csv we can use an external package called pandas which has to be installed
csvdata = pandas.read_csv("24.testcsv.csv")
print(csvdata)
print(csvdata["age"].to_list())
#average age
print(csvdata["age"].mean())

print(csvdata[csvdata.name == "Alex"])

for (index,row) in csvdata.iterrows():
    print(row.age)