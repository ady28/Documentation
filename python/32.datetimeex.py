#!/usr/bin/env python3

import datetime as dt

now = dt.datetime.now()
print(now)
print(now.year)
print(now.weekday())

birthday = dt.datetime(1988,12,6)
print(birthday)

print(birthday.strftime("Year is %Y"))