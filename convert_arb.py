import json
import re

def snake_to_camel(snake_str):
    components = snake_str.split('_')
    return components[0] + ''.join(x.title() for x in components[1:])

def convert_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    new_data = {}
    for key, value in data.items():
        new_key = snake_to_camel(key)
        new_data[new_key] = value
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)
    print(f"Converted {filepath}")

convert_file(r'd:\sishusuraksha\Shishu_suraksha\lib\l10n\app_en.arb')
convert_file(r'd:\sishusuraksha\Shishu_suraksha\lib\l10n\app_te.arb')
