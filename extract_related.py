import os
import glob

dirs_to_check = [
    "01_Game_Design",
    "02_Tech_Architecture",
    "06_Assets"
]

def extract_related_section(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        related_section = []
        in_related = False
        for line in lines:
            if line.strip().startswith("## Verwandt"):
                in_related = True
                related_section.append(line.strip())
                continue
            
            if in_related:
                if line.strip().startswith("## ") and not line.strip().startswith("## Verwandt"):
                    break # Next section
                related_section.append(line.strip())
                
        if related_section:
            print(f"--- File: {filepath} ---")
            print("\n".join(related_section))
            print()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")

for d in dirs_to_check:
    for root, _, files in os.walk(d):
        for file in files:
            if file.endswith(".md"):
                extract_related_section(os.path.join(root, file))
