# -*- coding: utf-8 -*-
import json

with open("i18n/languages.json", "r", encoding="utf-8") as f:
    languages = json.load(f)

# Master English pages
base_pages = [
    "https://lovecalc.click/",
    "https://lovecalc.click/name-compatibility.html",
    "https://lovecalc.click/zodiac-compatibility.html",
    "https://lovecalc.click/birthday-compatibility.html",
    "https://lovecalc.click/flames-game.html",
    "https://lovecalc.click/love-percentage-chart.html",
    "https://lovecalc.click/science-of-love.html",
    "https://lovecalc.click/methodology.html",
    "https://lovecalc.click/faq.html",
    "https://lovecalc.click/widget.html",
    "https://lovecalc.click/about.html",
    "https://lovecalc.click/contact.html",
    "https://lovecalc.click/editorial-policy.html",
    "https://lovecalc.click/disclaimer.html",
    "https://lovecalc.click/sitemap.html",
    "https://lovecalc.click/privacy-policy.html",
    "https://lovecalc.click/terms.html"
]

all_urls = list(base_pages)

# Add 39 language hubs
for l in languages:
    code = l["code"]
    if code != "en":
        all_urls.append(f"https://lovecalc.click/{code}/")

# Generate clean sitemap.xml
xml_lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
]

for url in all_urls:
    xml_lines.append('  <url>')
    xml_lines.append(f'    <loc>{url}</loc>')
    xml_lines.append('    <lastmod>2026-09-13</lastmod>')
    xml_lines.append('  </url>')

xml_lines.append('</urlset>')

with open("sitemap.xml", "w", encoding="utf-8") as f:
    f.write("\n".join(xml_lines) + "\n")

# Generate sitemap.txt
with open("sitemap.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(all_urls) + "\n")

print(f"Updated sitemap.xml and sitemap.txt with {len(all_urls)} URLs (17 core + 39 localized languages)!")
