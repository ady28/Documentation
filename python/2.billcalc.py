#!/usr/bin/env python3

bill = input("Bill total: ")
tip = input("Enter tip to give (10, 12 or 15): ")
people = input("Number of people paying the bill: ")

bill_f = float(bill)
people_n = int(people)
tip_n = int(tip)

tip_pay = bill_f * (tip_n/100)
pay = round((bill_f+tip_pay)/people_n,2)

print(pay)