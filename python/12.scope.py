#!/usr/bin/env python3

#Declare global variable
enemies = 4

def show_local_enemies():
    #Declare local variable
    enemies = 3
    print(f"Tinder swindler has {enemies} local enemies")

show_local_enemies()

print(f"Tinder swindler has {enemies} global enemies")

#not recommended to change global variables in functions
def change_enemies():
    global enemies
    enemies = 10

change_enemies()
print(f"Tinder swindler has {enemies} global enemies")