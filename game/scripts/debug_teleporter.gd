extends Node

# ============================================================================
# DebugTeleporter — deaktiviert.
# ============================================================================
# Die physischen Teleporter-Pads wurden entfernt. Teleportation ist jetzt
# ausschliesslich ueber das ADMIN-Panel im Pause-Menue verfuegbar
# (scripts/pause_menu.gd, Methode _build_admin_panel()).
# Dieses Script bleibt als Autoload registriert, tut aber nichts mehr.

func _ready() -> void:
	pass
