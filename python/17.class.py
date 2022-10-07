#!/usr/bin/env python3

class TestClass:
    def __init__(self, name,age):
        self.name = name
        self.age = age
    
    def birthday(self):
        self.age += 1

    def get_name(self):
        print(self.name)

    def get_age(self):
        print(self.age)

class ExtendedTestClass(TestClass):
    def __init__(self, name, age, weight):
        super().__init__(name, age)

        self.weight = weight
    
    def get_weight(self):
        print(self.weight)

    def eat_food(self):
        self.weight += 1

user1 = TestClass("Andrei",20)

user1.get_name()
user1.get_age()
user1.birthday()
user1.get_age()

user2 = ExtendedTestClass("Ovidiu",32,90)
user2.get_name()
user2.get_weight()
user2.eat_food()
user2.get_weight()