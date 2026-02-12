import os
import json

lang_dir = r"c:\Users\Parvathi\shishu_suraksha\assets\lang"
files = [f for f in os.listdir(lang_dir) if f.endswith('.json')]
en_path = os.path.join(lang_dir, "en.json")

# Load English Data as Reference
with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)
    en_districts = en_data.get("districts", []) # List[String]

# UI Keys Redundancy Check / Snake Case Enforcement
ui_key_updates = {
    "selectRole": "select_role",
    "anganwadiTeacher": "anganwadi_teacher",
    "selectDistrict": "select_district",
    "selectVillage": "select_village",
    "userId": "user_id",
    "signIn": "sign_in"
}

# Known Telugu Translations for Demo
te_translations = {
    "select_role": "పాత్రను ఎంచుకోండి",
    "admin": "అడ్మిన్",
    "anganwadi_teacher": "అంగన్‌వాడీ టీచర్",
    "select_district": "జిల్లాను ఎంచుకోండి",
    "select_village": "గ్రామాన్ని ఎంచుకోండి",
    "user_id": "వినియోగదారు ఐడి",
    "password": "పాస్వర్డ్",
    "sign_in": "సైన్ ఇన్"
}

for file in files:
    path = os.path.join(lang_dir, file)
    with open(path, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
        except:
            print(f"Skipping {file} due to error")
            continue
    
    # 1. Fix UI Keys (Camel -> Snake)
    for old, new in ui_key_updates.items():
        if old in data:
            data[new] = data[old]
            del data[old]
            
    # 2. Refactor Districts (List -> Map)
    local_districts_list = data.get("districts", [])
    if isinstance(local_districts_list, list):
        # Build Map: English Name -> Localized Name
        districts_map = {}
        # Mapping for re-keying other maps
        loc_to_en_map = {} 
        
        for i, en_name in enumerate(en_districts):
            if i < len(local_districts_list):
                loc_name = local_districts_list[i]
                districts_map[en_name] = loc_name
                loc_to_en_map[loc_name] = en_name
            else:
                districts_map[en_name] = en_name # Fallback
                
        data["districts"] = districts_map
        
        # 3. Refactor Villages (Re-key to English)
        old_villages = data.get("villages", {})
        new_villages = {}
        for k, v in old_villages.items():
            # k is Localized District Name
            # Find matching English name
            en_key = loc_to_en_map.get(k, k) # Use map, fallback to self (if already english or not found)
            new_villages[en_key] = v
        data["villages"] = new_villages
        
        # 4. Refactor User IDs (Re-key to English)
        old_uids = data.get("user_ids", {})
        new_uids = {}
        for k, v in old_uids.items():
            en_key = loc_to_en_map.get(k, k)
            new_uids[en_key] = v
        data["user_ids"] = new_uids

    # 5. Inject Telugu Translations (Only for te.json)
    if file == "te.json":
        for k, v in te_translations.items():
            data[k] = v

    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Refactored {file}")
