extends Area3D
class_name GoalZone

var _triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if _triggered:
		return
	# Gleicher Player-Erkennungs-Trick wie beim KillGate: prüft ob der
	# Body der Player ist (hat set_target aus dem Lock-On-System).
	if not body.has_method("set_target") and not body.is_in_group("player"):
		return

	_triggered = true

	var win_screen := get_tree().get_root().find_child("WinScreen", true, false)
	if win_screen and win_screen.has_method("show_win"):
		win_screen.show_win()
	else:
		push_warning("GoalZone: Konnte keinen Node namens 'WinScreen' finden.")
