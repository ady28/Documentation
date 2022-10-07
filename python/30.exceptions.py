#!/usr/bin/env python3

try:
    file = open("notexists.txt")
except FileNotFoundError as err_msg:
    print(f"There was an error opening the file: {err_msg}. Trying to create it.")
    file = open("notexists.txt",mode="w")
else:
    print("File exists.")
    content = file.read()
    print(content)
finally:
    file.close()
    print("End of the script.")

#Raise custom error
raise BlockingIOError("Just a custom error")