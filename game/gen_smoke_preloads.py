import os

base_dir = r"C:\Users\thvnh\Documents\GitHub\whiplash\game\assets\vfx\smoke"
allowed = ["004", "005", "007", "010", "011", "012", "013", "014"]

gd_code = "static var SMOKE_FRAMES: Array[SpriteFrames] = []\n\nstatic func _init_smoke_frames() -> void:\n\tif not SMOKE_FRAMES.is_empty(): return\n"

for f in allowed:
    folder = "smoke" + f
    full_path = os.path.join(base_dir, folder)
    if os.path.exists(full_path):
        pngs = sorted([p for p in os.listdir(full_path) if p.endswith(".png")])
        gd_code += f"\tvar frames_{f} := SpriteFrames.new()\n"
        gd_code += f"\tframes_{f}.add_animation(\"default\")\n"
        gd_code += f"\tframes_{f}.set_animation_speed(\"default\", 12)\n"
        gd_code += f"\tframes_{f}.set_animation_loop(\"default\", false)\n"
        for png in pngs:
            res_path = f"res://assets/vfx/smoke/{folder}/{png}"
            gd_code += f"\tframes_{f}.add_frame(\"default\", preload(\"{res_path}\"))\n"
        gd_code += f"\tSMOKE_FRAMES.append(frames_{f})\n\n"

with open(r"C:\Users\thvnh\Documents\GitHub\whiplash\game\smoke_gen.txt", "w") as out:
    out.write(gd_code)
