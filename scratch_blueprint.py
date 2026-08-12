import os
import glob
import re

blueprint = r'c:\Users\thvnh\Documents\GitHub\whiplash\05_Gedanken\02_Game_Design_Blueprint.md'
with open(blueprint, 'r', encoding='utf-8') as f:
    lines = f.readlines()

clean_lines = []
for line in lines:
    if line.startswith('</USER_REQUEST>'):
        break
    clean_lines.append(line)

out = ''.join(clean_lines)

table = '\n### Neue Basis-Items (Loot Pool Verdünnung)\n\n'
table += '| **Nr.** | **Typ** | **Rarity** | **Name** | **Mechanik** |\n'
table += '|---|---|---|---|---|\n'

idx = 1
for file in sorted(glob.glob(r'c:\Users\thvnh\Documents\GitHub\whiplash\01_Game_Design\Items\*.md')):
    if file.endswith('_MOC_Items.md'): continue
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    rarity = re.search(r'rarity:\s*\[?(.*?)\]?\n', content, re.I)
    itype = re.search(r'type:\s*\[?(.*?)\]?\n', content, re.I)
    if rarity:
        r_val = rarity.group(1).replace('"', '').replace("'", '').strip()
        if r_val.lower() in ['common', 'uncommon']:
            name = os.path.basename(file).replace('.md', '')
            t_val = itype.group(1).replace('"', '').replace("'", '').strip() if itype else 'Unknown'
            desc = re.search(r'>\s*\*(.*?)\*', content)
            d_val = desc.group(1) if desc else '-'
            table += f'| {idx} | {t_val} | {r_val} | [[{name}]] | {d_val} |\n'
            idx += 1

out += table

with open(blueprint, 'w', encoding='utf-8') as f:
    f.write(out)
print('Updated blueprint successfully.')
