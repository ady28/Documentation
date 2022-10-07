#!/usr/bin/env python3

import requests

response = requests.get(url="http://lnx1:8090/api/v1/stocks/VALE")
print(response.status_code)
#Generate exception if we get a bad status code
response.raise_for_status()

data = response.json()
print(data)
print(data["data"]["lastupdated"])

params = {
    "page" : 1,
    "limit" : 10,
    "select" : "ticker,name,roic"
}
response = requests.get(url="http://lnx1:8090/api/v1/stocks", params=params)
data = response.json()["data"]
print(data)
for stock in data:
    print(stock["name"])