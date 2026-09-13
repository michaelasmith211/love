# -*- coding: utf-8 -*-
import os, json, re

with open("i18n/languages.json", "r", encoding="utf-8") as f:
    languages = json.load(f)

with open("i18n/translations.json", "r", encoding="utf-8") as f:
    translations = json.load(f)

with open("index.html", "r", encoding="utf-8") as f:
    template = f.read()

# Build Hreflang Tags Block
hreflang_lines = ['  <link rel="alternate" hreflang="x-default" href="https://lovecalc.click/">']
for l in languages:
    code = l["code"]
    hl_code = "zh-Hans" if code == "zh" else ("zh-Hant" if code == "zh-TW" else code)
    url = "https://lovecalc.click/" if code == "en" else f"https://lovecalc.click/{code}/"
    hreflang_lines.append(f'  <link rel="alternate" hreflang="{hl_code}" href="{url}">')

hreflang_block = "\n".join(hreflang_lines)

# Language Button HTML
lang_btn_html = """        <button id="btn-lang-selector" class="lang-selector-btn" aria-label="Change Language">
          <span class="lang-icon" aria-hidden="true">🌐</span>
          <span class="lang-current-code">EN</span>
          <span class="lang-chevron" aria-hidden="true">▼</span>
        </button>"""

# Language Modal HTML
lang_modal_html = """  <!-- Language Switcher Modal -->
  <div id="lang-modal" class="modal-overlay hidden" role="dialog" aria-modal="true" aria-labelledby="lang-modal-title">
    <div class="modal-content lang-modal-content">
      <button id="close-lang-modal" class="modal-close" aria-label="Close Language Modal">&times;</button>
      <div class="lang-modal-header">
        <h3 id="lang-modal-title">Select Your Language</h3>
        <input type="search" id="lang-search-input" placeholder="Search 40 languages..." class="lang-search-box" autocomplete="off">
      </div>
      <div class="lang-grid" id="lang-grid-container"></div>
    </div>
  </div>"""

# Ensure index.html has hreflang, lang button, modal, and i18n.js
if "hreflang=" not in template:
    template = re.sub(r'(<link rel="canonical"[^>]*>)', r'\1\n' + hreflang_block, template)

if "btn-lang-selector" not in template:
    template = template.replace('<div class="header-actions">', '<div class="header-actions" style="display: flex; align-items: center; gap: 10px;">\n' + lang_btn_html)

if "lang-modal" not in template:
    template = template.replace('</body>', lang_modal_html + '\n  <script src="./js/i18n.js" defer></script>\n</body>')

with open("index.html", "w", encoding="utf-8") as f:
    f.write(template)

print("Updated master index.html with language switcher & hreflang block!")

# Generate 39 localized subdirectories
generated = 0
for l in languages:
    code = l["code"]
    if code == "en":
        continue
    
    tr = translations.get(code, {})
    if not tr:
        print(f"Warning: missing translation for {code}")
        continue
    
    os.makedirs(code, exist_ok=True)
    html = template
    
    # 1. Update <html lang="..." dir="...">
    direction = l.get("dir", "ltr")
    html = re.sub(r'<html lang="en"[^>]*>', f'<html lang="{code}" dir="{direction}">', html)
    
    # 2. Update canonical link
    html = re.sub(r'<link rel="canonical" href="https://lovecalc.click/">', f'<link rel="canonical" href="https://lovecalc.click/{code}/">', html)
    
    # 3. Update Title & Meta description
    title = tr.get("title", "")
    meta_desc = tr.get("meta_desc", "")
    og_title = tr.get("og_title", title)
    og_desc = tr.get("og_desc", meta_desc)
    
    html = re.sub(r'<title>.*?</title>', f'<title>{title}</title>', html)
    html = re.sub(r'<meta name="description" content=".*?">', f'<meta name="description" content="{meta_desc}">', html)
    html = re.sub(r'<meta property="og:title" content=".*?">', f'<meta property="og:title" content="{og_title}">', html)
    html = re.sub(r'<meta property="og:description" content=".*?">', f'<meta property="og:description" content="{og_desc}">', html)
    html = re.sub(r'<meta property="og:url" content="https://lovecalc.click/">', f'<meta property="og:url" content="https://lovecalc.click/{code}/">', html)
    
    # 4. Update relative paths for assets/css/js from /{code}/ to root
    html = html.replace('href="./css/style.css"', 'href="../css/style.css"')
    html = html.replace('href="./manifest.json"', 'href="../manifest.json"')
    html = html.replace('href="./assets/', 'href="../assets/')
    html = html.replace('src="./js/', 'src="../js/')
    html = html.replace('src="./assets/', 'src="../assets/')
    html = html.replace('href="./"', f'href="../{code}/"')
    
    # 5. Update UI Text
    if "hero_title" in tr:
        html = re.sub(r'<h1 class="hero-title">.*?</h1>', f'<h1 class="hero-title">{tr["hero_title"]}</h1>', html, flags=re.DOTALL)
    if "hero_sub" in tr:
        html = re.sub(r'<p class="hero-subtitle">.*?</p>', f'<p class="hero-subtitle">{tr["hero_sub"]}</p>', html, flags=re.DOTALL, count=1)
        
    # Tabs
    if "tab_names" in tr:
        html = html.replace('data-tab="names">\n            <span class="tab-icon" aria-hidden="true">🔤</span> Names', f'data-tab="names">\n            <span class="tab-icon" aria-hidden="true">🔤</span> {tr["tab_names"]}')
    if "tab_zodiac" in tr:
        html = html.replace('data-tab="zodiac">\n            <span class="tab-icon" aria-hidden="true">♈</span> Zodiac', f'data-tab="zodiac">\n            <span class="tab-icon" aria-hidden="true">♈</span> {tr["tab_zodiac"]}')
    if "tab_bday" in tr:
        html = html.replace('data-tab="birthday">\n            <span class="tab-icon" aria-hidden="true">🎂</span> Birthday', f'data-tab="birthday">\n            <span class="tab-icon" aria-hidden="true">🎂</span> {tr["tab_bday"]}')
    if "tab_flames" in tr:
        html = html.replace('data-tab="flames">\n            <span class="tab-icon" aria-hidden="true">🔥</span> FLAMES', f'data-tab="flames">\n            <span class="tab-icon" aria-hidden="true">🔥</span> {tr["tab_flames"]}')
        
    # Form Labels & Buttons
    if "label_name1" in tr:
        html = re.sub(r'<label for="name1" class="input-label">.*?</label>', f'<label for="name1" class="input-label">{tr["label_name1"]}</label>', html)
    if "label_name2" in tr:
        html = re.sub(r'<label for="name2" class="input-label">.*?</label>', f'<label for="name2" class="input-label">{tr["label_name2"]}</label>', html)
    if "placeholder_name1" in tr:
        html = re.sub(r'id="name1" placeholder="[^"]*"', f'id="name1" placeholder="{tr["placeholder_name1"]}"', html)
    if "placeholder_name2" in tr:
        html = re.sub(r'id="name2" placeholder="[^"]*"', f'id="name2" placeholder="{tr["placeholder_name2"]}"', html)
    if "btn_calc_names" in tr:
        html = re.sub(r'<button type="submit" id="btn-calc-names" class="submit-btn">\s*<span>.*?</span>', f'<button type="submit" id="btn-calc-names" class="submit-btn">\n            <span>{tr["btn_calc_names"]}</span>', html)
        
    if "btn_download_card" in tr:
        html = html.replace('Download Official Love Card', tr["btn_download_card"])
    if "btn_embed" in tr:
        html = html.replace('Embed on Website', tr["btn_embed"])
    if "btn_recalculate" in tr:
        html = html.replace('Calculate Another Match', tr["btn_recalculate"])
        
    # Update Current Language text in header button
    html = html.replace('<span class="lang-current-code">EN</span>', f'<span class="lang-current-code">{code.upper()}</span>')
    
    # Update JSON-LD inLanguage
    html = html.replace('"@type": "WebApplication",', f'"@type": "WebApplication",\n    "inLanguage": "{code}",')
    html = html.replace('"@type": "WebSite",', f'"@type": "WebSite",\n    "inLanguage": "{code}",')
    
    target_file = os.path.join(code, "index.html")
    with open(target_file, "w", encoding="utf-8") as f:
        f.write(html)
    generated += 1

print(f"Generated {generated} localized language subdirectories!")
