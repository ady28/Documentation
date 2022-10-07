#!/usr/bin/env python3

def func1(name):
    """Test function"""
    print(f"Hi {name} from func!")

func1("Adi")
func1("Andrei")
func1(name="Sorin")

def format_name(f_name, l_name):
    """Return first and last name with capital letters"""
    return f"{f_name} {l_name}".title()
final_name=format_name("adi","dumitras")
print(final_name)