import os
import re

# Define the mapping of snake_case to camelCase for common patterns
replacements = {
    r't\.([a-z]+)_([a-z_]+)': lambda m: f"t.{m.group(1) + ''.join(word.capitalize() for word in m.group(2).split('_'))}"
}

def fix_localization_keys(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Apply regex replacements
        for pattern, replacement in replacements.items():
            content = re.sub(pattern, replacement, content)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed: {file_path}")
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def process_directory(directory):
    fixed_count = 0
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                if fix_localization_keys(file_path):
                    fixed_count += 1
    return fixed_count

# Process the lib directory
lib_dir = r'd:\sishusuraksha\Shishu_suraksha\lib'
count = process_directory(lib_dir)
print(f"\nTotal files fixed: {count}")
