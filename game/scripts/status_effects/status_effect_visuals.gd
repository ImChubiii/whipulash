# res://scripts/status_effects/status_effect_visuals.gd
extends Node
class_name StatusEffectVisuals

# ============================================================================
# Dauerhafte visuelle Rueckmeldung fuer laufende Status-Effekte.
# ============================================================================
# PROBLEM, DAS DIESE DATEI LOEST:
# psx.gdshader hat GENAU EIN Paar flash_color/flash_strength. Der Hit-Flash in
# enemy_ai.gd faehrt es per Tween hoch und wieder auf 0 — jeder dauerhafte
# Tint, den ein Status-Effekt setzt, wird davon beim naechsten Treffer
# geloescht. Ein brennender Gegner hoerte also auf zu gluehen, sobald man ihn
# schlug: genau in dem Moment, in dem man hinschaut.
#
# LOESUNG: Dieser Node schreibt den Tint JEDEN FRAME neu. Der Hit-Flash-Tween
# laeuft weiterhin und ueberschreibt kurz — im naechsten Frame steht der Tint
# wieder. Sichtbares Ergebnis: der Gegner gluent dauerhaft in der Effektfarbe
# und blitzt bei Treffern trotzdem kurz heller auf.
#
# WARUM NICHT PARTIKEL: GPUParticles3D pro Gegner und Effekt waeren bei 30+
# Gegnern im Raum spuerbar teurer, und der Tint liest sich auf PSX-Modellen
# ohnehin deutlicher als ein Partikelschleier.
#
# EINBAU: wird von enemy_ai.gd automatisch mit erzeugt (siehe dort
# _setup_status_visuals()). Manuell noetig ist nichts.

## Prioritaet von oben nach unten — der oberste ZUTREFFENDE Effekt gewinnt.
## Ein betaeubter, brennender Gegner zeigt Stun, weil das die Information
## ist, auf die der Spieler reagieren muss.
const PRIORITY: PackedStringArray = [
	"stun", "rooted", "charm", "confused", "silenced", "burn", "acid", "bleed", "poison", "slow"
]

## Wie stark die Grundfarbe pulsiert (0 = konstant).
const PULSE_AMOUNT: float = 0.18
const PULSE_SPEED: float = 6.0

var _manager: StatusEffectManager = null
var _materials: Array[ShaderMaterial] = []
var _pulse: float = 0.0
var _active_id: String = ""


static func attach(owner: Node) -> StatusEffectVisuals:
	var existing := owner.get_node_or_null("StatusEffectVisuals") as StatusEffectVisuals
	if existing != null:
		return existing
	var node := StatusEffectVisuals.new()
	node.name = "StatusEffectVisuals"
	owner.add_child(node)
	return node


func _ready() -> void:
	var owner_node: Node = get_parent()
	if owner_node == null:
		return

	# Kinder werden VOR dem Elternknoten ready; der StatusEffectManager wird
	# aber erst in dessen _ready() erzeugt. Ohne das await waere _manager
	# garantiert null.
	if not owner_node.is_node_ready():
		await owner_node.ready
	if not is_instance_valid(owner_node):
		return

	_manager = StatusEffectBase.manager_of(owner_node)
	_collect_materials(owner_node)
	set_process(_manager != null and not _materials.is_empty())


func _collect_materials(node: Node) -> void:
	var mesh := node as MeshInstance3D
	if mesh != null:
		# material_override hat Vorrang vor surface_material_override —
		# deshalb zuerst pruefen. Steht dort ein ShaderMaterial, sind die
		# Surface-Overrides ohnehin wirkungslos.
		if mesh.material_override is ShaderMaterial:
			_materials.append(mesh.material_override as ShaderMaterial)
		else:
			for i: int in range(mesh.get_surface_override_material_count()):
				var surface: Material = mesh.get_surface_override_material(i)
				if surface is ShaderMaterial:
					_materials.append(surface as ShaderMaterial)
	for child: Node in node.get_children():
		_collect_materials(child)


func _process(delta: float) -> void:
	if _manager == null or not is_instance_valid(_manager):
		set_process(false)
		return

	var id: String = _dominant_effect()
	if id == "":
		if _active_id != "":
			_clear_tint()
			_active_id = ""
		return

	_active_id = id
	_pulse = fmod(_pulse + delta * PULSE_SPEED, TAU)

	var visual: Dictionary = _visual_for(id)
	var color: Color = visual["color"]
	var strength: float = float(visual["strength"]) * (1.0 - PULSE_AMOUNT + PULSE_AMOUNT * (0.5 + 0.5 * sin(_pulse)))

	for material: ShaderMaterial in _materials:
		if is_instance_valid(material):
			material.set_shader_parameter("flash_color", color)
			material.set_shader_parameter("flash_strength", strength)


func _clear_tint() -> void:
	for material: ShaderMaterial in _materials:
		if is_instance_valid(material):
			material.set_shader_parameter("flash_strength", 0.0)


func _dominant_effect() -> String:
	for id: String in PRIORITY:
		if _manager.has_effect(id):
			return id
	return ""


## Farbe UND Staerke fuer einen Effekt in EINEM Lookup statt zwei parallelen
## match-Bloecken ueber dieselben IDs, die sonst bei jeder Aenderung von Hand
## synchron gehalten werden muessten. Der Farbkreis-Trick fuer "confused"
## (HOLOGRAM_RAINBOW aus dem Design-Dokument) dreht die Grundfarbe ueber die
## Zeit im HSV-Raum. "bleed"/"poison" haben (noch) keine eigene Status*-
## Klasse (siehe status_effect_manager.gd::DOT_IDS) - deshalb hier weiterhin
## als Literal-Fallback statt TINT_COLOR/TINT_STRENGTH-Konstanten.
func _visual_for(id: String) -> Dictionary:
	match id:
		StatusStun.ID:
			return {"color": StatusStun.TINT_COLOR, "strength": StatusStun.TINT_STRENGTH}
		StatusRooted.ID:
			return {"color": StatusRooted.TINT_COLOR, "strength": StatusRooted.TINT_STRENGTH}
		StatusCharm.ID:
			return {"color": StatusCharm.TINT_COLOR, "strength": StatusCharm.TINT_STRENGTH}
		StatusSilenced.ID:
			return {"color": StatusSilenced.TINT_COLOR, "strength": StatusSilenced.TINT_STRENGTH}
		StatusBurn.ID:
			return {"color": StatusBurn.TINT_COLOR, "strength": StatusBurn.TINT_STRENGTH}
		StatusAcid.ID:
			return {"color": StatusAcid.TINT_COLOR, "strength": StatusAcid.TINT_STRENGTH}
		StatusSlow.ID:
			return {"color": StatusSlow.TINT_COLOR, "strength": StatusSlow.TINT_STRENGTH}
		StatusConfused.ID:
			var hue: float = fmod(Time.get_ticks_msec() * 0.001 * StatusConfused.RAINBOW_SPEED, 1.0)
			return {"color": Color.from_hsv(hue, 0.75, 1.0), "strength": StatusConfused.TINT_STRENGTH}
		"bleed":
			return {"color": Color(0.85, 0.10, 0.12), "strength": 0.30}
		"poison":
			return {"color": Color(0.45, 0.85, 0.30), "strength": 0.30}
	return {"color": Color(1.0, 1.0, 1.0), "strength": 0.30}
