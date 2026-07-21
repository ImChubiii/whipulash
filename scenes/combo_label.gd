extends Control

# --- Node-Referenzen auf die UI-Elemente ---
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var combo_label: Label = $ComboLabel

# --- Referenzen auf die Komponenten des Players ---
# Werden zur Laufzeit gesucht (siehe _ready), damit du im Editor nichts
# manuell verknüpfen musst — funktioniert, solange dein Player-Node
# im Szenenbaum "Player" heißt und die entsprechenden Kind-Nodes hat.
var player_health: Health
var player_combat: Combat

func _ready() -> void:
	combo_label.visible = false
	# Kurz warten, bis alle Nodes in der Szene bereit sind
	await get_tree().process_frame
	_find_and_connect_player_health()
	_find_and_connect_player_combat()

func _find_and_connect_player_health() -> void:
	# Sucht rekursiv im ganzen Szenenbaum nach einem Node namens "Player"
	var player := get_tree().get_root().find_child("Player", true, false)
	if player == null:
		push_warning("HUD: Konnte keinen Node namens 'Player' finden.")
		return

	var health_node := player.find_child("Health", true, false)
	if health_node == null or not (health_node is Health):
		push_warning("HUD: Player hat keine Health-Komponente (Kind-Node 'Health').")
		return

	player_health = health_node
	# Signal verbinden: sobald sich die HP ändern, wird _on_health_changed aufgerufen
	player_health.health_changed.connect(_on_health_changed)

	# Direkt beim Start einmal die Anzeige mit den aktuellen Werten füllen
	_on_health_changed(player_health.current_health, player_health.max_health)

func _on_health_changed(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current
	health_label.text = "%d / %d" % [current, max_hp]

func _find_and_connect_player_combat() -> void:
	var player := get_tree().get_root().find_child("Player", true, false)
	if player == null:
		return

	var combat_node := player.find_child("Combat", true, false)
	if combat_node == null or not (combat_node is Combat):
		push_warning("HUD: Player hat keine Combat-Komponente (Kind-Node 'Combat').")
		return

	player_combat = combat_node
	player_combat.combo_changed.connect(_on_combo_changed)

func _on_combo_changed(count: int) -> void:
	if count <= 1:
		# Combo verfallen oder noch kein zweiter Treffer → Anzeige ausblenden
		combo_label.visible = false
		return

	combo_label.visible = true
	combo_label.text = "x%d COMBO!" % count

	# Kleiner "Punch"-Effekt bei jedem neuen Combo-Treffer: kurz größer
	# werden lassen und zurückfedern, macht's spürbarer/befriedigender.
	combo_label.scale = Vector2(1.4, 1.4)
	var tween := create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
