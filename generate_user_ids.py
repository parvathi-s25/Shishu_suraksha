import os
import json

lang_dir = r"c:\Users\Parvathi\shishu_suraksha\assets\lang"
files = [f for f in os.listdir(lang_dir) if f.endswith('.json')]

# Manual mapping based on user examples and standard codes
district_code_map = {
    "Alluri Sitharama Raju": "ASR",
    "Anakapalli": "AKP",
    "Anantapuramu": "ATP",
    "Annamayya": "ANM",
    "Bapatla": "BPT",
    "Chittoor": "CTR",
    "Dr. B.R. Ambedkar Konaseema": "KON",
    "East Godavari": "EGD",
    "Eluru": "ELR",
    "Guntur": "GNT",
    "Kakinada": "KKD",
    "Konaseema": "KON",
    "Krishna": "KRI",
    "Kurnool": "KRL", # User example
    "Nandyal": "NDL", # User example
    "NTR": "NTR",
    "Palnadu": "PLN",
    "Parvathipuram Manyam": "PVM",
    "Prakasam": "PRK",
    "Sri Potti Sriramulu Nellore": "NLR",
    "Sri Sathya Sai": "SSS",
    "Srikakulam": "SKL",
    "Tirupati": "TPT", # User example
    "Visakhapatnam": "VSP",
    "Vizianagaram": "VZM",
    "West Godavari": "WGD",
    "YSR": "YSR"
}

def get_ids(district_name_en):
    code = district_code_map.get(district_name_en, district_name_en[:3].upper())
    return [f"{code}AT{str(i).zfill(3)}" for i in range(1, 6)]

# First, read English to get the master list of districts
with open(os.path.join(lang_dir, "en.json"), 'r', encoding='utf-8') as f:
    en_data = json.load(f)
    en_districts = en_data.get("districts", [])

# Now process all files
for file in files:
    path = os.path.join(lang_dir, file)
    with open(path, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
        except:
            print(f"Error reading {file}")
            continue
    
    # Get the translated districts from THIS file
    # We assume the order matches the English list (standard practice in this app so far)
    # If "districts" key doesn't exist, we skip
    if "districts" not in data:
        print(f"Skipping {file} (no districts key)")
        continue
        
    local_districts = data["districts"]
    
    # Generate the user_ids map
    user_ids_map = {}
    
    # We iterate through the ENGLISH districts to get the CODE, 
    # but use the LOCAL district name as the KEY.
    # This assumes en_districts and local_districts are parallel arrays.
    for i, en_name in enumerate(en_districts):
        if i < len(local_districts):
            local_name = local_districts[i]
            user_ids_map[local_name] = get_ids(en_name)
            
    data["user_ids"] = user_ids_map
    
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Updated {file} with user_ids")
