# -*- coding: utf-8 -*-
import os, json, re
from onpage_translations import ONPAGE_DATA

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

# Ensure master index.html has hreflang, lang button, modal, and i18n.js
if "hreflang=" not in template:
    template = re.sub(r'(<link rel="canonical"[^>]*>)', r'\1\n' + hreflang_block, template)

if "btn-lang-selector" not in template:
    template = template.replace('<div class="header-actions">', '<div class="header-actions" style="display: flex; align-items: center; gap: 10px;">\n' + lang_btn_html)

if "lang-modal" not in template:
    template = template.replace('</body>', lang_modal_html + '\n  <script src="./js/i18n.js" defer></script>\n</body>')

with open("index.html", "w", encoding="utf-8") as f:
    f.write(template)

print("Master index.html verified & updated.")

# Generate 39 localized subdirectories
generated = 0
for l in languages:
    code = l["code"]
    if code == "en":
        continue
    
    tr = translations.get(code, {})
    if not tr:
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
    html = re.sub(r'<meta http-equiv="content-language" content="en">', f'<meta http-equiv="content-language" content="{code}">', html)
    
    # 4. Update relative paths for assets/css/js from /{code}/ to root
    html = html.replace('href="./css/style.css"', 'href="../css/style.css"')
    html = html.replace('href="./manifest.json"', 'href="../manifest.json"')
    html = html.replace('href="./assets/', 'href="../assets/')
    html = html.replace('src="./js/', 'src="../js/')
    html = html.replace('src="./assets/', 'src="../assets/')
    html = html.replace('srcset="./assets/', 'srcset="../assets/')
    html = html.replace('href="./"', f'href="../{code}/"')
    
    # Update internal page navigation links so they point to root pages correctly
    pages_to_fix = [
        "name-compatibility.html",
        "zodiac-compatibility.html",
        "birthday-compatibility.html",
        "flames-game.html",
        "love-percentage-chart.html",
        "science-of-love.html",
        "methodology.html",
        "faq.html",
        "widget.html",
        "about.html",
        "contact.html",
        "editorial-policy.html",
        "disclaimer.html",
        "sitemap.html",
        "privacy-policy.html",
        "terms.html"
    ]
    for p in pages_to_fix:
        html = html.replace(f'href="./{p}"', f'href="../{p}"')
        
    html = html.replace("navigator.serviceWorker.register('./sw.js')", "navigator.serviceWorker.register('../sw.js')")
    
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
        html = re.sub(r'<label for="calc-name1" class="input-label">.*?</label>', f'<label for="calc-name1" class="input-label">{tr["label_name1"]}</label>', html)
        html = re.sub(r'<label for="name1" class="input-label">.*?</label>', f'<label for="name1" class="input-label">{tr["label_name1"]}</label>', html)
    if "label_name2" in tr:
        html = re.sub(r'<label for="calc-name2" class="input-label">.*?</label>', f'<label for="calc-name2" class="input-label">{tr["label_name2"]}</label>', html)
        html = re.sub(r'<label for="name2" class="input-label">.*?</label>', f'<label for="name2" class="input-label">{tr["label_name2"]}</label>', html)
    if "placeholder_name1" in tr:
        html = re.sub(r'id="calc-name1" class="text-input" placeholder="[^"]*"', f'id="calc-name1" class="text-input" placeholder="{tr["placeholder_name1"]}"', html)
        html = re.sub(r'id="name1" placeholder="[^"]*"', f'id="name1" placeholder="{tr["placeholder_name1"]}"', html)
    if "placeholder_name2" in tr:
        html = re.sub(r'id="calc-name2" class="text-input" placeholder="[^"]*"', f'id="calc-name2" class="text-input" placeholder="{tr["placeholder_name2"]}"', html)
        html = re.sub(r'id="name2" placeholder="[^"]*"', f'id="name2" placeholder="{tr["placeholder_name2"]}"', html)
    if "btn_calc_names" in tr:
        html = re.sub(r'<button type="submit" class="submit-btn" id="btn-calc-names">\s*<span>.*?</span>', f'<button type="submit" class="submit-btn" id="btn-calc-names">\n                  <span>{tr["btn_calc_names"]}</span>', html)
        
    if "label_zodiac1" in tr:
        html = re.sub(r'<label for="zodiac-sign1" class="input-label">.*?</label>', f'<label for="zodiac-sign1" class="input-label">{tr["label_zodiac1"]}</label>', html)
    if "label_zodiac2" in tr:
        html = re.sub(r'<label for="zodiac-sign2" class="input-label">.*?</label>', f'<label for="zodiac-sign2" class="input-label">{tr["label_zodiac2"]}</label>', html)
    if "btn_calc_zodiac" in tr:
        html = re.sub(r'<button type="submit" class="submit-btn" id="btn-calc-zodiac">\s*<span>.*?</span>', f'<button type="submit" class="submit-btn" id="btn-calc-zodiac">\n                  <span>{tr["btn_calc_zodiac"]}</span>', html)
        
    if "label_bday1" in tr:
        html = re.sub(r'<label for="bday-date1" class="input-label">.*?</label>', f'<label for="bday-date1" class="input-label">{tr["label_bday1"]}</label>', html)
    if "label_bday2" in tr:
        html = re.sub(r'<label for="bday-date2" class="input-label">.*?</label>', f'<label for="bday-date2" class="input-label">{tr["label_bday2"]}</label>', html)
    if "btn_calc_bday" in tr:
        html = re.sub(r'<button type="submit" class="submit-btn" id="btn-calc-bday">\s*<span>.*?</span>', f'<button type="submit" class="submit-btn" id="btn-calc-bday">\n                  <span>{tr["btn_calc_bday"]}</span>', html)

    if "btn_download_card" in tr:
        html = html.replace('Download Official Love Card', tr["btn_download_card"])
    if "btn_embed" in tr:
        html = html.replace('Embed on Website', tr["btn_embed"])
    if "btn_recalculate" in tr:
        html = html.replace('Calculate Another Match', tr["btn_recalculate"])
        
    # Update Current Language text in header button
    html = html.replace('<span class="lang-current-code">EN</span>', f'<span class="lang-current-code">{code.upper()}</span>')
    
    # 6. Deep On-Page Localizations from ONPAGE_DATA
    op = ONPAGE_DATA.get(code)
    if op:
        # E-E-A-T Badges
        html = html.replace('Medically & Psychologically Reviewed', op.get("eeat_reviewed", "Medically & Psychologically Reviewed"))
        html = html.replace('By Relationship Researchers & Behavioral Analysts', op.get("eeat_reviewed_sub", "By Relationship Researchers & Behavioral Analysts"))
        html = html.replace('4.9 / 5.0 Rating', op.get("eeat_rating", "4.9 / 5.0 Rating"))
        html = html.replace('Based on 14,820+ verified community reviews', op.get("eeat_rating_sub", "Based on 14,820+ verified community reviews"))
        html = html.replace('Updated for 2026', op.get("eeat_updated", "Updated for 2026"))
        
        # Features Grid
        html = html.replace('100% Private & Client-Side', op.get("feat_1_title", "100% Private & Client-Side"))
        html = html.replace('Calculations happen directly in your browser. We never save, log, or sell your personal names or birthdates.', op.get("feat_1_desc", ""))
        html = html.replace('Deterministic Algorithm', op.get("feat_2_title", "Deterministic Algorithm"))
        html = html.replace('No random numbers. Names and dates generate authentic, consistent percentages and metrics every single time.', op.get("feat_2_desc", ""))
        html = html.replace('Viral Social Cards', op.get("feat_3_title", "Viral Social Cards"))
        html = html.replace('Download HD certificates formatted for Instagram Stories, WhatsApp status, Snapchat, and TikTok sharing.', op.get("feat_3_desc", ""))
        html = html.replace('Zero Lag Core Web Vitals', op.get("feat_4_title", "Zero Lag Core Web Vitals"))
        html = html.replace('Engineered with lightweight native standards for instantaneous page speeds on mobile, tablet, and desktop.', op.get("feat_4_desc", ""))
        
        # Article 1 (Percentage Chart)
        if "art1_cat" in op:
            html = html.replace('Love Score Interpretation Guide', op["art1_cat"])
        if "art1_h2" in op:
            html = html.replace('Love Compatibility Percentage Chart: What Does Your Score Mean?', op["art1_h2"])
        if "art1_p1" in op:
            html = re.sub(r'<p>\s*When you run a test on our <strong>Love Calculator</strong>.*?</p>', f'<p>{op["art1_p1"]}</p>', html, flags=re.DOTALL)
        if "th_range" in op:
            html = html.replace('<th scope="col">Match Range</th>', f'<th scope="col">{op["th_range"]}</th>')
        if "th_tier" in op:
            html = html.replace('<th scope="col">Compatibility Tier</th>', f'<th scope="col">{op["th_tier"]}</th>')
        if "th_dynamics" in op:
            html = html.replace('<th scope="col">Emotional & Chemistry Dynamics</th>', f'<th scope="col">{op["th_dynamics"]}</th>')
        if "th_advice" in op:
            html = html.replace('<th scope="col">Relationship Advice</th>', f'<th scope="col">{op["th_advice"]}</th>')
        if "takeaway_title" in op:
            html = html.replace('<h4>💡 Key Takeaway for Couples:</h4>', f'<h4>{op["takeaway_title"]}</h4>')
        if "takeaway_desc" in op:
            html = html.replace('A score in any bracket has the potential to become a lifelong loving partnership. Real relationships are forged through daily dedication, emotional vulnerability, and mutual kindness.', op["takeaway_desc"])
        
        # Article 2 (How It Works)
        if "art2_cat" in op:
            html = html.replace('Algorithmic Science & Romance', op["art2_cat"])
        if "art2_h2" in op:
            html = html.replace('How Does the Love Calculator Work? The Science of Compatibility', op["art2_h2"])
        if "art2_p1" in op:
            html = re.sub(r'<p>\s*Throughout human history, people have sought ways to predict romantic destiny.*?</p>', f'<p>{op["art2_p1"]}</p>', html, flags=re.DOTALL)
            
        # Article 3 (5 Love Languages)
        if "art3_cat" in op:
            html = html.replace('Relationship Psychology', op["art3_cat"])
        if "art3_h2" in op:
            html = html.replace('The 5 Love Languages: How Understanding Affection Elevates Compatibility', op["art3_h2"])
        if "art3_p1" in op:
            html = re.sub(r'<p>\s*Introduced by counselor Dr\. Gary Chapman.*?</p>', f'<p>{op["art3_p1"]}</p>', html, flags=re.DOTALL)

        # Article 4 (Zodiac)
        if "art4_cat" in op:
            html = html.replace('Astrology & Synastry', op["art4_cat"])
        if "art4_h2" in op:
            html = html.replace('Zodiac Compatibility & Astrological Element Harmony Chart', op["art4_h2"])
        if "art4_p1" in op:
            html = re.sub(r'<p>\s*Astrological love compatibility \(Synastry\).*?</p>', f'<p>{op["art4_p1"]}</p>', html, flags=re.DOTALL)

        # Article 5 (Numerology)
        if "art5_h2" in op:
            html = html.replace('Life Path Numbers in Romantic Numerology', op["art5_h2"])

        # Article 6 (FLAMES)
        if "art6_h2" in op:
            html = html.replace('The FLAMES Love Test: Rules & Meaning', op["art6_h2"])

        # FAQs in HTML
        if "faq_title" in op:
            html = html.replace('<h2>Love Calculator FAQs</h2>', f'<h2>{op["faq_title"]}</h2>')
            html = html.replace('<div class="article-category">Frequently Asked Questions</div>', f'<div class="article-category">{op["faq_title"]}</div>')
        if "faq_sub" in op:
            html = html.replace('Answers to the most common questions about romantic compatibility, algorithms, and relationship chemistry.', op['faq_sub'])
        
        # Build localized FAQ Accordion HTML and Schema
        if "faqs" in op and op["faqs"]:
            faq_items_html = []
            faq_schema_items = []
            for fq in op["faqs"]:
                q_text = fq["q"]
                a_text = fq["a"]
                faq_items_html.append(f"""        <div class="faq-item">
          <button class="faq-question" aria-expanded="false">
            <span>{q_text}</span>
            <span class="faq-icon" aria-hidden="true">+</span>
          </button>
          <div class="faq-answer">
            <p>{a_text}</p>
          </div>
        </div>""")
                faq_schema_items.append({
                    "@type": "Question",
                    "name": q_text,
                    "acceptedAnswer": {
                        "@type": "Answer",
                        "text": a_text
                    }
                })
                
            new_faq_list = "\n".join(faq_items_html)
            html = re.sub(r'<div class="faq-list">[\s\S]*?</div>\s*</section>', f'<div class="faq-list">\n{new_faq_list}\n      </div>\n    </section>', html)
            
            # Replace FAQPage Schema in <head> with localized questions
            loc_faq_schema = json.dumps({
                "@context": "https://schema.org",
                "@type": "FAQPage",
                "inLanguage": code,
                "mainEntity": faq_schema_items
            }, ensure_ascii=False, indent=2)
            
            html = re.sub(r'<!-- 4\. FAQPage Schema[^>]*-->\s*<script type="application/ld\+json">[\s\S]*?</script>',
                          f'<!-- 4. FAQPage Schema (Localized) -->\n  <script type="application/ld+json">\n{loc_faq_schema}\n  </script>', html)
                          
        # Footer
        if "footer_disclaimer" in op:
            html = re.sub(r'<p class="disclaimer-text">.*?</p>', f'<p class="disclaimer-text">{op["footer_disclaimer"]}</p>', html, flags=re.DOTALL)
        if "footer_copy" in op:
            html = re.sub(r'&copy; 2026 lovecalc\.click\..*?</p>', f'{op["footer_copy"]}</p>', html)

    # Update JSON-LD inLanguage for WebApplication, WebSite, and ImageObject
    html = html.replace('"@type": "WebApplication",', f'"@type": "WebApplication",\n    "inLanguage": "{code}",')
    html = html.replace('"@type": "WebSite",', f'"@type": "WebSite",\n    "inLanguage": "{code}",')
    html = html.replace('"@type": "ImageObject",', f'"@type": "ImageObject",\n    "inLanguage": "{code}",')
    
    target_file = os.path.join(code, "index.html")
    with open(target_file, "w", encoding="utf-8") as f:
        f.write(html)
    generated += 1

print(f"Successfully generated all {generated} full on-page multilingual directories!")
