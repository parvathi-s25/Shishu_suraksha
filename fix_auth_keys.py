import os
import json

lang_dir = r"c:\Users\Parvathi\shishu_suraksha\assets\lang"
files = [f for f in os.listdir(lang_dir) if f.endswith('.json')]

# Mapping old camelCase to new snake_case
key_map = {
    "selectRole": "select_role",
    "anganwadiTeacher": "anganwadi_teacher",
    "selectDistrict": "select_district",
    "selectVillage": "select_village",
    "userId": "user_id",
    "signIn": "sign_in"
}

# Ensure these keys exist (with defaults if missing)
required_keys = {
    "select_role": "Select Role",
    "admin": "Admin",
    "anganwadi_teacher": "Anganwadi Teacher",
    "select_district": "Select District",
    "select_village": "Select Village",
    "user_id": "User ID",
    "password": "Password",  # Already valid, but good to ensure
    "sign_in": "Sign In"
}

for file in files:
    path = os.path.join(lang_dir, file)
    with open(path, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
        except:
            data = {}
    
    modified = False
    
    # 1. Rename Keys
    for old_key, new_key in key_map.items():
        if old_key in data and new_key not in data:
            data[new_key] = data[old_key]
            del data[old_key]
            modified = True
        elif old_key in data and new_key in data:
            # If both exist, just delete old
             del data[old_key]
             modified = True

    # 2. Ensure Required Keys
    for k, v in required_keys.items():
        if k not in data:
            data[k] = v
            modified = True
            
    if modified:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"Updated {file}")
    else:
        print(f"No changes for {file}")
