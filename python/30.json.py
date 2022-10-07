#!/usr/bin/env python3

import pandas

j = pandas.read_json(path_or_buf="30.testjson.json", typ="series", orient="records")
for person in j["People"]:
    print(person["Name"])