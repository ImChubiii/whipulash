import os
import glob
import re

kaykit_dir = r"C:\Users\thvnh\Documents\GitHub\whiplash\game\assets\environments\KayKit_Dungeon_Pack_1.1_FREE\Assets"

def simplify_name(name):
    # The user wants simple names. e.g. "barrel_large_B" -> "barrel"
    # Wait, if barrel_large_B and barrel_large_A both become "barrel", they will overwrite each other!
    # I should just remove _A, _B, _C etc if it's not going to clash, or add a number.
    # Actually, we can remove the suffix, but if it exists, maybe append a number.
    return name.replace("_FREE", "")

# We will just write a PowerShell script to rename them interactively or do it via python.
# Since the prompt said "rename alle props von KayKit_Dungeon_Pack_1.1_FREE damit die ein simplen namen haben"
# I can just strip common suffixes.
