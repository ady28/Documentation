#!/usr/bin/env python3

from urllib import response
from bs4 import BeautifulSoup
import requests

response = requests.get("https://www.marketbeat.com/stocks/NASDAQ/AMD/competitors-and-alternatives/")
to_parse = response.text

soup = BeautifulSoup(to_parse, "html.parser")
competitors_html = soup.find_all(class_="ticker-area")

competitors=[]

for comp in competitors_html:
    competitors.append(comp.getText())

print(competitors)