import os
import json

lang_dir = r"c:\Users\Parvathi\shishu_suraksha\assets\lang"
files = [f for f in os.listdir(lang_dir) if f.endswith('.json')]

new_keys = {
    "chatbot_title": "Chatbot",
    "chatbot_placeholder": "Type a message...",
    "helpline_title": "Helpline",
    "call_supervisor": "Call Supervisor",
    "email_support": "Email Support",
    "whatsapp_support": "WhatsApp Support",
    "nearest_phc": "Nearest PHC",
    "emergency_contact": "Emergency Contact"
}

for file in files:
    path = os.path.join(lang_dir, file)
    with open(path, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
        except:
            data = {}
    
    modified = False
    for k, v in new_keys.items():
        if k not in data:
            data[k] = v
            modified = True
            
    if modified:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"Updated {file}")
    else:
        print(f"No changes for {file}")
