#!/usr/bin/env python3

#Install a package: pip install prettytable

from prettytable import PrettyTable

table = PrettyTable()
table.add_column("Name",["Alex","Radu","Mihai"])
table.add_column("Age",[21,33,11])
table.align = "l"

print(table)