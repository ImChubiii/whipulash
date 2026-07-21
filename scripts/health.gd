extends Node
class_name Health

# --- Signals: andere Nodes (UI, Sound, VFX) können darauf reagieren, ---
# --- ohne dass diese Komponente wissen muss, WER zuhört. ---
signal health_changed(current: float, max: float)
signal died

@export var max_health: float = 100.0

# --- Regeneration ---
@export var regen_enabled: bool = true
@export var regen_rate: float = 5.0       # HP pro Sekunde, sobald Regen aktiv ist
@export var regen_delay: float = 3.0      # Sekunden Wartezeit nach dem letzten Treffer

var current_health: float
var _time_since_damage: float = 0.0

# Merkt sich, WER/WAS zuletzt Schaden verursacht hat — z.B. für
# richtungsabhängige Todes-Animationen (fällt weg vom Angreifer).
var last_damage_source: Node3D = null

func _ready() -> void:
	current_health = max_health

func _process(delta: float) -> void:
	if not regen_enabled or not is_alive():
		return

	_time_since_damage += delta

	if _time_since_damage >= regen_delay and current_health < max_health:
		heal(regen_rate * delta)

func take_damage(amount: float, source: Node3D = null) -> void:
	if current_health <= 0.0:
		return  # bereits tot, ignoriere weitere Treffer

	current_health = max(current_health - amount, 0.0)
	_time_since_damage = 0.0  # Regen-Timer zurücksetzen bei jedem Treffer
	last_damage_source = source
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func is_alive() -> bool:
	return current_health > 0.0
