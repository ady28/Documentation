#!/usr/bin/env python3

import random

letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
numbers = ["0","1","2","3","4","5","6","7","8","9"]
characters = ["!","@",",",".","#","$","%","^","&"]

letter_no = int(input("Enter the letter number:"))
number_no = int(input("Enter the number of numbers: "))
char_no = int(input("Enter the number of special characters: "))

password_length = letter_no + number_no + char_no

password = []
for i in range(1,letter_no+1):
    password.append(random.choice(letters))
for i in range(1,number_no+1):
    password.append(random.choice(numbers))
for i in range(1,char_no+1):
    password.append(random.choice(characters))

random.shuffle(password)

passw = ""
for c in password:
    passw+=c

print(passw)