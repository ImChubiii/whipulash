# res://scripts/level/goal_zone.gd
extends Area3D
class_name GoalZone

# ============================================================================
# GoalZone — Ausgang einer Etage.
# ============================================================================
# PHASE 3.2: Frueher hat die Zone IMMER direkt den WinScreen gezeigt. Jetzt
# wird zuerst versucht, in die naechste Etage zu wechseln; der WinScreen
# kommt nur noch, wenn es keine naechste Etage mehr gibt (letzte Etage
# erreicht oder StageManager nicht registriert).
#
# WARUM _triggered ZURUECKGESETZT WIRD:
# Die Zone lebt in der RAUM-Szene und wird beim Etagenwechsel mit dem alten
# Raum abgeraeumt — die neue Etage bringt ihre eigene mit. Das Zuruecksetzen
# ist trotzdem drin, damit eine wiederverwendete Zone (Testszene ohne
# Neuaufbau) beim zweiten Durchlauf nicht tot ist.

var _triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if _triggered:
		return
	# Gleicher Player-Erkennungs-Trick wie beim KillGate: prueft ob der Body
	# der Player ist (hat set_target aus dem Lock-On-System).
	if not body.has_method("set_target") and not body.is_in_group("player"):
		return

	_triggered = true

	# --- Etagenwechsel versuchen -----------------------------------------
	var stages: Node = get_node_or_null("/root/Stages")
	if stages != null and stages.has_method("advance_stage"):
		if stages.advance_stage():
			# Erfolgreich gewechselt. _triggered bleibt gesetzt, der Raum
			# verschwindet ohnehin gleich.
			return
	else:
		push_warning("[GoalZone] Autoload 'Stages' nicht gefunden — es geht direkt zum WinScreen. Bitte res://scripts/level/stage_manager.gd als Autoload 'Stages' eintragen.")

	_show_win_screen()


func _show_win_screen() -> void:
	var win_screen := get_tree().get_root().find_child("WinScreen", true, false)
	if win_screen and win_screen.has_method("show_win"):
		win_screen.show_win()
	else:
		push_warning("GoalZone: Konnte keinen Node namens 'WinScreen' finden.")
