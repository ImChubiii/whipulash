import json
import os
import re

transcript_path = r"C:\Users\thvnh\.gemini\antigravity\brain\28746c2b-96dc-4115-8db9-e8b5346c4ad0\.system_generated\logs\transcript_full.jsonl"
out_dir = r"c:\Users\thvnh\Documents\GitHub\whiplash\05_Gedanken"

def clean_view_file_output(text):
    lines = text.split("\n")
    cleaned = []
    start_parsing = False
    for line in lines:
        if line.startswith("The following code has been modified to include a line number"):
            start_parsing = True
            continue
        if line.startswith("The above content shows the entire"):
            break
        if start_parsing:
            m = re.match(r"^\d+: (.*)", line)
            if m:
                cleaned.append(m.group(1))
            else:
                m2 = re.match(r"^\d+:$", line)
                if m2:
                    cleaned.append("")
                else:
                    cleaned.append(line)
    return "\n".join(cleaned)

with open(transcript_path, 'r', encoding='utf-8') as f:
    for line_str in f:
        try:
            step = json.loads(line_str)
        except:
            continue
            
        if "tool_calls" in step and step["tool_calls"]:
            for tc in step["tool_calls"]:
                if tc.get("name") == "default_api:write_to_file":
                    args = tc.get("arguments", {})
                    target_file = args.get("TargetFile", "")
                    if target_file and "05_Gedanken" in target_file:
                        content = args.get("CodeContent", "")
                        with open(target_file, "w", encoding="utf-8") as out:
                            out.write(content)
                            print(f"Recovered from write_to_file: {target_file}")
                            
        if step.get("type") == "TOOL_RESPONSES" and "tool_responses" in step:
            for tr in step["tool_responses"]:
                if tr.get("name") == "default_api:view_file":
                    out_text = tr.get("response", {}).get("output", "")
                    if "03_Item_Database.md" in out_text:
                        content = clean_view_file_output(out_text)
                        if content.strip():
                            with open(os.path.join(out_dir, "03_Item_Database.md"), "w", encoding="utf-8") as out:
                                out.write(content)
                                print(f"Recovered from view_file: 03_Item_Database.md")
                                
        if step.get("type") == "USER_INPUT":
            content = step.get("content", "")
            if "Brainstorming-Sammlung für neue Raum-Konzepte" in content:
                idx = content.find("# Raum-Ideen")
                if idx != -1:
                    ideen_content = content[idx:]
                    with open(os.path.join(out_dir, "02_Game_Design_Blueprint.md"), "w", encoding="utf-8") as out:
                        out.write(ideen_content)
                        print(f"Recovered from user prompt: 02_Game_Design_Blueprint.md")
