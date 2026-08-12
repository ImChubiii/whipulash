import os
import glob

def add_tags_to_file(filepath, tags_to_add):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if the file has frontmatter
    if not content.startswith('---'):
        print(f"Skipping {filepath} (No frontmatter)")
        return
        
    parts = content.split('---', 2)
    if len(parts) < 3:
        print(f"Skipping {filepath} (Invalid frontmatter)")
        return
        
    frontmatter = parts[1]
    
    # Check which tags are missing and add them
    lines = frontmatter.strip().split('\n')
    for tag in tags_to_add:
        if not any(line.startswith(tag.split(':')[0]) for line in lines):
            lines.append(tag)
            
    new_frontmatter = '\n'.join(lines)
    new_content = f"---\n{new_frontmatter}\n---{parts[2]}"
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Updated {filepath}")

# Process Enemies
enemy_files = glob.glob(r'c:\Users\thvnh\Documents\GitHub\whiplash\01_Game_Design\Enemies\*.md')
for filepath in enemy_files:
    if "_MOC" in filepath:
        continue
    add_tags_to_file(filepath, ['alternative_names: []'])

# Process Characters
character_files = glob.glob(r'c:\Users\thvnh\Documents\GitHub\whiplash\01_Game_Design\Characters\*.md')
for filepath in character_files:
    if "_MOC" in filepath:
        continue
    add_tags_to_file(filepath, [
        'alternative_names: []',
        'alternative_names_primary: []',
        'alternative_names_secondary: []'
    ])
