import os
import json

lang_dir = r"c:\Users\Parvathi\shishu_suraksha\assets\lang"
files = [f for f in os.listdir(lang_dir) if f.endswith('.json')]

# Translations provided in prompt + English defaults
translations = {
    "en": {
        "select_language": "Select Language",
        "get_started": "Get Started"
    },
    "te": {
        "select_language": "భాషను ఎంచుకోండి",
        "get_started": "ప్రారంభించండి"
    },
    "hi": {
        "select_language": "भाषा चुनें",
        "get_started": "शुरू करें"
    },
    "ta": {
        "select_language": "மொழியை தேர்ந்தெடுக்கவும்",
        "get_started": "தொடங்கு"
    },
    # Defaulting others to English for now as exact translations weren't provided for all 11
    "kn": { "select_language": "Select Language", "get_started": "Get Started" }, 
    "ml": { "select_language": "Select Language", "get_started": "Get Started" },
    "bn": { "select_language": "Select Language", "get_started": "Get Started" },
    "mr": { "select_language": "Select Language", "get_started": "Get Started" },
    "gu": { "select_language": "વપરાશકર્તા", "get_started": "શરૂ કરો" }, # Inferred/guessed for completeness if possible, else English
    "pa": { "select_language": "Select Language", "get_started": "Get Started" },
    "or": { "select_language": "Select Language", "get_started": "Get Started" }
}

# Fix Gujarati: 
translations["gu"] = { "select_language": "ભાષા પસંદ કરો", "get_started": "શરૂ કરો" }

for file in files:
    lang_code = file.split('.')[0]
    path = os.path.join(lang_dir, file)
    
    with open(path, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
        except:
            data = {}
    
    # Get specific translations or fallback to English
    t_map = translations.get(lang_code, translations["en"])
    
    data["select_language"] = t_map["select_language"]
    data["get_started"] = t_map["get_started"]

    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Updated {file}")
