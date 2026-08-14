import os
import re

room_instance_file = r"C:\Users\thvnh\Documents\GitHub\whiplash\game\scenes\level_generation\room_instance.gd"
wiki_file = r"C:\Users\thvnh\Documents\GitHub\whiplash\wiki\06_Assets\breakable_props.md"

def extract_props():
    props = set()
    with open(room_instance_file, "r") as f:
        content = f.read()
    
    # We know the strings are in arrays like FLOOR_PROP_FILES, NEAR_TABLE_PROP_FILES, etc.
    # Let's match lines that contain things like "barrel_large", "box", etc.
    # Actually, we can just look at the specific arrays we care about:
    match_floor = re.search(r'const FLOOR_PROP_FILES: PackedStringArray = \[(.*?)\]', content, re.DOTALL)
    match_near = re.search(r'const NEAR_TABLE_PROP_FILES: PackedStringArray = \[(.*?)\]', content, re.DOTALL)
    match_wall = re.search(r'const WALL_PROP_FILES: PackedStringArray = \[(.*?)\]', content, re.DOTALL)
    
    all_str = ""
    if match_floor: all_str += match_floor.group(1)
    if match_near: all_str += match_near.group(1)
    if match_wall: all_str += match_wall.group(1)
    
    matches = re.findall(r'"([^"]+)"', all_str)
    for m in matches:
        props.add(m)
    return props

def simplify(name):
    s = name.replace("_A", "").replace("_B", "").replace("_C", "")
    s = s.replace("_decorated", "").replace("_stack", "")
    return s.replace("_", " ").title()

def create_wiki():
    props = extract_props()
    simple_props = sorted(list(set(simplify(p) for p in props if p)))
    
    with open(wiki_file, "w", encoding="utf-8") as f:
        f.write("---\n")
        f.write("tags:\n")
        f.write("  - Asset\n")
        f.write("  - Environment\n")
        f.write("  - Breakable\n")
        f.write("---\n\n")
        f.write("# Breakable Props (KayKit Dungeon Pack)\n\n")
        f.write("> Diese Props wurden aus dem `KayKit_Dungeon_Pack_1.1_FREE` importiert.\n")
        f.write("> Sie werden über `room_instance.gd` geladen und als `BreakableProp` (`game/scripts/environment/breakable_prop.gd`) instanziiert.\n")
        f.write("> \n")
        f.write("> **Eigenschaften**:\n")
        f.write("> - **HP**: 20\n")
        f.write("> - **Spezial**: Verlieren Deckkraft (Opacity) je nach verbleibenden HP, ähnlich wie bei den Enemies.\n\n")
        f.write("## Prop-Liste\n\n")
        
        for p in simple_props:
            f.write(f"- [[{p}]]\n")
            
        f.write("\n## Verweise\n")
        f.write("- [[environment_assets]]\n")
        f.write("- [[character_models]]\n")
    
    print("Wiki created at", wiki_file)

if __name__ == "__main__":
    create_wiki()
