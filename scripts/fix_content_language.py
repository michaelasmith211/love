# -*- coding: utf-8 -*-
import os, json, re

with open("i18n/languages.json", "r", encoding="utf-8") as f:
    languages = json.load(f)

for l in languages:
    code = l["code"]
    if code == "en":
        continue
    path = os.path.join(code, "index.html")
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            c = f.read()
        c = re.sub(r'<meta http-equiv="content-language" content="en">', f'<meta http-equiv="content-language" content="{code}">', c)
        with open(path, "w", encoding="utf-8") as f:
            f.write(c)

print("Updated content-language meta tag in all 39 localized HTML files!")
