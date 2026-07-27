extends CharacterBody3D
class_name EnemyAI

enum State { IDLE, CHASE, ATTACK }

## PSX-Shader fuer alle Oberflaechen des Gegners. Wird zur Laufzeit auf jede
## Surface des importierten Modells gelegt, damit Hit-Flash und
## HP-Transparenz weiterhin funktionieren (das .glb bringt normale
## StandardMaterial3D mit, die keine alpha_multiplier/flash_strength kennen).
const PSX_SHADER: Shader = preload("res://shaders/psx.gdshader")

@export var move_speed: float = 7.0

# --- Individuelle Geschwindigkeits-Streuung -------------------------------
# Jede gespawnte Instanz wuerfelt EINMALIG in _ready() einen eigenen
# Multiplikator zwischen (1 - speed_variance) und (1 + speed_variance).
# Dadurch laufen mehrere Gegner desselben Typs nicht mehr wie auf einer
# Schnur hintereinander her, sondern ziehen sich beim Verfolgen leicht
# auseinander — der Unterschied ist bewusst klein genug, um nicht wie ein
# Balancing-Fehler zu wirken, aber gross genug um spuerbar zu sein.
# 0.0 = alle Instanzen exakt gleich schnell (altes Verhalten).
@export_range(0.0, 0.5) var speed_variance: float = 0.12

@export var detection_range: float = 20.0
@export var attack_range: float = 5.0
@export var attack_cooldown: float = 1.0

# --- Angriffs-Freigabe (Fix: "greift ins Leere") --------------------------
# Frueher wurde ein Angriff gestartet, sobald distance <= attack_range war,
# und die Hitbox danach BEDINGUNGSLOS aktiviert — auch wenn der Spieler
# waehrend pre_attack_delay + attack_windup_time laengst weggelaufen war
# oder von Anfang an ausserhalb der tatsaechlichen Hitbox-Reichweite stand
# (attack_range war groesser als die reale Reichweite der AttackHitbox).
# Ergebnis: Gegner schlagen sichtbar in die Luft.
#
# Jetzt wird die Distanz DIREKT VOR dem Aktivieren der Hitbox erneut
# geprueft. Liegt der Spieler weiter weg als attack_range * diesem Faktor,
# wird der Angriff sauber abgebrochen (Telegraph aus, kurzer Cooldown,
# zurueck in CHASE) statt ins Leere zu schlagen.
@export var attack_commit_range_multiplier: float = 1.15

# Cooldown nach einem abgebrochenen Angriff — kurz, damit der Gegner sofort
# wieder nachsetzen kann, aber lang genug um kein Telegraph-Flackern zu
# erzeugen.
@export var attack_abort_cooldown: float = 0.3

## Wie stark die Separation von anderen Gegnern waehrend eines laufenden
## Angriffs noch wirkt. 0 = gar nicht.
##
## WARUM ES DIESEN WERT BRAUCHT (behobener Fehler "Angriff trifft nie"):
## Die State-Machine setzt im ATTACK-Zustand velocity.x/z auf 0 — der Gegner
## soll beim Zuschlagen stehenbleiben. Direkt danach wurde aber
## BEDINGUNGSLOS _get_separation_velocity() draufaddiert.
##
## Genau im Angriffsmoment stehen alle Gegner dicht am Spieler, also auch
## dicht beieinander. Die Separation zeigt damit vom Pulk weg — und der Pulk
## ist der Spieler. Ueber pre_attack_delay + attack_windup_time (Standard
## 0.8 + 1.0 = 1.8 s) driftete ein Fighter so weit zurueck, dass die
## AttackHitbox beim Zuschlagen ins Leere zeigte. Fuer den Spieler sah es
## aus, als wuerde der Gegner ausholen und dann grundlos zurueckweichen.
##
## Ein kleiner Restwert (Standard 0.12) bleibt bewusst stehen: bei zwei
## Gegnern, die exakt uebereinander stehen, waere 0.0 eine Einladung, sich
## dauerhaft zu verkeilen.
@export_range(0.0, 1.0) var attack_separation_factor: float = 0.12

# Minimaler Blickrichtungs-Abgleich, damit ein Angriff ueberhaupt startet.
# Verhindert Schlaege, die seitlich am Spieler vorbeigehen, weil der Gegner
# sich noch dreht.
# 1.0 = exakt frontal, 0.0 = 90 Grad Toleranz, -1.0 = Check deaktiviert.
#
# ACHSEN-FALLE (hat in der ersten Fassung ALLE Angriffe blockiert):
# Godots Node3D-Konvention ist -Z = vorne. DIESES Projekt nutzt aber
# durchgehend +Z als Vorne — sichtbar an zwei Stellen:
#   1. _face_player() rechnet atan2(dir.x, dir.z) und richtet damit die
#      +Z-Achse auf den Spieler aus (fuer -Z waere es atan2(-x, -z)).
#   2. Die AttackHitbox sitzt bei z = +8.2 (dummy.tscn/tank_dummy.tscn),
#      also auf der POSITIVEN Z-Seite.
# Ein Check gegen -basis.z liefert deshalb dauerhaft ein Dot-Produkt von
# etwa -1 und der Gegner greift NIE an. Deshalb wird die Blickrichtung
# jetzt nicht mehr aus der Basis gelesen, sondern direkt gegen dieselbe
# Ziel-Yaw geprueft, die auch _face_player() ansteuert — damit koennen die
# beiden Stellen gar nicht mehr auseinanderlaufen.
@export_range(-1.0, 1.0) var attack_min_facing_dot: float = 0.35

# gravity hat einen Setter, damit jump_velocity automatisch neu berechnet
# wird, falls gravity zur Laufzeit (Inspector-Live-Edit, Debug-Tools etc.)
# veraendert wird — sonst bliebe die Sprungkraft auf Basis der ALTEN
# gravity "eingefroren".
@export var gravity: float = 20.0:
	set(value):
		gravity = value
		_recalculate_jump_velocity()

@export var attack_windup_time: float = 1.0
@export var pre_attack_delay: float = 0.8

# Eigener Anzeigename fuer UI/Death-Screen — unabhaengig vom technischen
# Godot-Node-Namen (der bei gespawnten Kopien haesslich werden kann, z.B.
# "@CharacterBody3D@3").
@export var display_name: String = "Gegner"

func get_display_name() -> String:
	return display_name

# Markiert diesen Gegner als "gross" — Kamera zoomt beim Lock-On automatisch
# raus auf zoom_max, statt bei der aktuellen manuellen Zoomstufe zu bleiben.
@export var is_large_enemy: bool = false

# Schwere Gegner koennen vom Player nicht weggestossen werden (Knockback
# vom Player's Hitbox wird ignoriert). Im Inspector aktivieren fuer Fighter, Colossus etc.
@export var is_heavy: bool = false

# Hoehe, auf der der Lock-On-Ring ueber DIESEM Gegner erscheint.
@export var reticle_height_offset: float = 1.2

# Wie weit der Ring Richtung Kamera vor DIESEM Gegner schwebt.
@export var reticle_forward_offset: float = 1.0

# Skaliert die GROESSE des Lock-On-Rings passend zur Gegnergroesse.
@export var reticle_scale: float = 1.0

# Multiplikator fuer die Staerke des Kamera-Soft-Locks, wenn dieser Gegner
# gerade als Ziel gelockt ist.
@export var camera_lock_multiplier: float = 1.0

# --- Sanfte Separation von anderen Gegnern ---
@export var separation_radius: float = 6.0
@export var separation_strength: float = 5.0

## --- Zickzack-Verfolgung (Scout/Stinger) ------------------------------
## Ein Gegner, der schnurgerade auf den Spieler zulaeuft, ist trivial zu
## treffen und fuehlt sich wie ein Zielobjekt an, nicht wie ein Jaeger.
##
## MUSTER: zick - stehen - zack - stehen. Der Gegner setzt also einen
## schraegen Sprint an, friert kurz ein, und setzt dann schraeg in die
## ANDERE Richtung an. Das Einfrieren ist der eigentliche Trick: es macht
## den naechsten Richtungswechsel unvorhersehbar, weil man waehrend der
## Pause nicht sieht, wohin es weitergeht.
##
## Der Ausschlag wird kurz vor dem Ziel ausgeblendet - sonst zieht der
## Gegner im letzten Meter dauernd am Spieler vorbei und kommt nie in
## attack_range. In der Pausenphase gilt dasselbe: innerhalb von
## zigzag_min_distance wird NICHT mehr angehalten, sonst bliebe er direkt
## vor dem Spieler stehen statt zuzuschlagen.
##
## Standard AUS, damit traege Typen (Fighter, Colossus) unveraendert
## geradeaus laufen. Einschalten in der jeweiligen Gegner-Szene.
@export var zigzag_enabled: bool = false

## Seitlicher Ausschlag eines Beins. 55 Grad heisst: gut die Haelfte der
## Geschwindigkeit geht in die Seitwaertsbewegung (cos 55 = 0.57 Vortrieb).
## Ueber 70 Grad kommt er praktisch nicht mehr naeher.
@export_range(0.0, 80.0) var zigzag_angle_degrees: float = 55.0

## Wie lange EIN schraeges Bein laeuft, bevor angehalten wird.
@export var zigzag_leg_time: float = 0.35

## Standzeit zwischen zwei Beinen.
@export var zigzag_pause_time: float = 0.4

## Wie hart in der Pause abgebremst wird. Hoch = schlagartiger Stopp,
## niedrig = ausrollen. Deutlich ueber movement_acceleration setzen,
## damit die Pause auch als Pause gelesen wird.
@export var zigzag_brake_acceleration: float = 90.0

## Ab hier laeuft er schnurgerade durch und pausiert nicht mehr.
@export var zigzag_min_distance: float = 3.5

## Ab dieser Entfernung ist der Ausschlag voll ausgefahren. Dazwischen
## wird linear geblendet.
@export var zigzag_fade_distance: float = 10.0

## Ab welchem Ausschlags-Anteil ueberhaupt noch pausiert wird.
##
## WARUM: Bei 0.32 s Bein und 0.4 s Pause ist der Gegner nur 44 % der Zeit
## in Bewegung, und davon geht bei 58 Grad noch die Haelfte zur Seite. Ein
## fliehender Spieler waere damit schlicht schneller und der Stinger holt
## nie auf. Unterhalb dieser Schwelle laeuft er deshalb durch (der Winkel
## wird ohnehin schon ausgeblendet) und pausiert erst wieder, wenn er
## Abstand hat.
@export_range(0.0, 1.0) var zigzag_pause_min_amount: float = 0.45

## --- Fokus-Verlust ----------------------------------------------------
## Eine Horde, in der jeder Gegner exakt dasselbe tut, liest sich als EIN
## Schwarm - egal wie viele es sind. Sobald einzelne aber zwischendurch
## das Interesse verlieren, kurz woanders hinlaufen und dann wieder
## andocken, zerfaellt die Formation in viele eigenstaendige Nervensaegen.
##
## Waehrend der Ablenkung greift der Gegner NICHT an und schaut in seine
## Laufrichtung statt zum Spieler - das ist der sichtbare Unterschied zu
## "verfolgt dich gerade".
##
## Ein laufender Angriff wird nie unterbrochen: der Wuerfel laeuft nur,
## solange _is_attacking false ist. Sonst wuerden Telegraph und Hitbox
## mitten in der Animation abbrechen.
@export var focus_loss_enabled: bool = false

## Erwartete Aussetzer pro Sekunde. 0.35 heisst grob: alle drei Sekunden
## einer. Wird ueber eine Poisson-Verteilung in eine Pro-Frame-Chance
## umgerechnet, damit das Ergebnis NICHT von der Bildrate abhaengt.
@export var focus_loss_chance_per_second: float = 0.35

@export var focus_loss_duration_min: float = 0.5
@export var focus_loss_duration_max: float = 1.4

## Tempo waehrend der Ablenkung, als Anteil der normalen Geschwindigkeit.
@export_range(0.0, 1.0) var focus_loss_wander_speed_factor: float = 0.5

var _focus_lost_timer: float = 0.0
var _wander_direction: Vector3 = Vector3.ZERO

## Zufaelliger Startpunkt im Takt pro Instanz. Ohne das laeuft eine ganze
## Gruppe im Gleichschritt und sieht aus wie eine Marschformation.
@export var zigzag_random_phase: bool = true

## Taktphasen: 0 = Bein nach rechts, 1 = Pause, 2 = Bein nach links,
## 3 = Pause. Ungerade Indizes sind also immer Pausen.
var _zigzag_phase_index: int = 0
var _zigzag_timer: float = 0.0
var _zigzag_holding: bool = false

# Sauberer Ausstieg aus einem angefangenen Angriff: Telegraph aus, kurzer
# Cooldown, zurueck ins Verfolgen. Wird NICHT aufgerufen, wenn der Gegner
# stirbt — dafuer ist _on_died() zustaendig.
func _abort_attack() -> void:
	_is_attacking = false
	_attack_timer = maxf(attack_abort_cooldown, 0.0)

	# Sonst bleibt der Arm in der Ausholpose stehen.
	_end_attack_swing()

	if telegraph_inner:
		telegraph_inner.visible = false
	if telegraph_outer:
		telegraph_outer.visible = false

	if _state == State.ATTACK:
		_state = State.CHASE

# --- Transparenz nach HP + Hit-Flash ---
@export_range(0.0, 1.0) var min_alpha_at_zero_hp: float = 0.15
@export_range(0.0, 1.0) var hit_flash_alpha: float = 0.2
@export var hit_flash_duration: float = 0.15

@export_range(0.0, 1.0) var hit_color_flash_strength: float = 0.25
@export var hit_color_flash_duration: float = 0.15

# --- Telegraph-Ring Boden-Snapping ---
@export var telegraph_ground_snap: bool = true
@export var telegraph_ground_clearance: float = 0.02
@export var telegraph_ground_raycast_mask: int = 1
@export var telegraph_ground_raycast_range: float = 20.0

# --- Sprung- & Kanten-Verhalten ---
@export var can_jump: bool = true

@export var jump_height: float = 2.0:
	set(value):
		jump_height = value
		_recalculate_jump_velocity()

@export var obstacle_jump_margin: float = 0.3
var jump_velocity: float = 0.0

@export var obstacle_check_distance: float = 1.2
@export var obstacle_check_low_height: float = 0.3
@export var ledge_check_forward_distance: float = 1.0
@export var ledge_check_drop_distance: float = 3.0
@export var ledge_wait_enabled: bool = true
@export var can_jump_across_ledges: bool = false
@export var jump_across_max_gap: float = 4.0
@export var ground_raycast_mask: int = 1

# Kanten-Check skaliert dynamisch mit der tatsaechlichen Kapselgroesse
# (Radius) dieses Gegners, damit grosse Gegner (Fighter, Colossus) nicht
# schon ueber den eigenen Koerper faelschlich "Abgrund" erkennen.
@export var ledge_check_scale_with_radius: bool = true
@export var ledge_check_radius_margin: float = 0.5

# Zusaetzlich zum mittleren Raycast werden zwei seitlich versetzte
# Raycasts geprueft — eine Kante wird nur erkannt, wenn ALLE drei
# Raycasts keinen Boden finden.
@export var ledge_check_lateral_samples: bool = true

@export var movement_acceleration: float = 40.0

# --- NavMesh-Pfadverfolgung ---
# Wie oft (in Sekunden) das Ziel des NavigationAgent3D neu gesetzt wird.
@export var nav_target_update_interval: float = 0.2

# --- Ledge-Drop-Verhalten (greift NUR, wenn KEIN gueltiger NavMesh-
# Pfad zum Spieler existiert) ---
@export var ledge_drop_enabled: bool = true
@export var max_safe_drop_height: float = 4.0
@export var ledge_drop_probe_distance: float = 15.0
@export var ledge_drop_player_below_margin: float = 1.0

# --- Abrutsch-Logik, wenn der Gegner auf dem Player-Kopf steht ---
@export var player_head_slide_impulse: float = 6.0
@export_range(0.0, 1.0) var player_head_slide_normal_threshold: float = 0.4
@export var player_head_slide_min_height_above_player: float = 0.3

var _waiting_at_ledge: bool = false

# Cooldown damit der Slide-Impuls nicht jeden Frame ueberschrieben wird
# und move_and_slide() ihn sofort wieder killt.
var _slide_cooldown: float = 0.0

# --- Knockback (z.B. von Hitboxen mit knockback_force, is_heavy schuetzt) ---
# Gleiches Prinzip wie in player_base.gd: _state-abhaengige Bewegung
# (IDLE/ATTACK setzen velocity.x/z direkt auf 0, CHASE regelt per
# move_toward) wuerde einen direkten velocity-Impuls sofort wieder
# ueberschreiben. Der Puffer wird stattdessen additiv angewendet und
# klingt eigenstaendig ab.
@export var knockback_friction: float = 10.0
var _knockback_velocity: Vector3 = Vector3.ZERO

func apply_knockback(impulse: Vector3) -> void:
	_knockback_velocity.x += impulse.x
	_knockback_velocity.z += impulse.z
	velocity.y += impulse.y

# --- Status-Effekt-System (Poison, Slow, Fear, ...) ---
var status_effects: StatusEffectManager

func apply_status_effect(id: String, duration: float, magnitude: float = 1.0, source: Node = null, tick_interval: float = 0.0) -> void:
	status_effects.apply_effect(id, duration, magnitude, source, tick_interval)

func has_status_effect(id: String) -> bool:
	return status_effects.has_effect(id)

func get_status_effect_magnitude(id: String) -> float:
	return status_effects.get_effect_magnitude(id)

func _on_status_effect_ticked(id: String, magnitude: float, source: Node) -> void:
	if id == "poison" and health:
		health.take_damage(magnitude, source)

# --- Debug ---
@export var debug_logging: bool = false

# --- 3D-Modell, Material & Animation --------------------------------------

## Name des Kind-Knotens, unter dem die importierte .glb-Szene haengt.
## Fehlt der Knoten, faellt alles auf den alten Kapsel-Platzhalter
## ("MeshInstance3D") zurueck -- nicht umgebaute Szenen laufen unveraendert.
@export var model_node_name: String = "CharacterModel"

## Die .glb enthaelt ALLE drei Roboter (Armature.RA / .RB / .RC) in EINER
## Szene, und der eine AnimationPlayer bespielt auch alle drei gleichzeitig.
## Loeschen der ungenutzten Armatures wuerde tote Animations-Tracks
## hinterlassen, deshalb werden sie hier zur Laufzeit nur ausgeblendet.
## Der Vergleich laeuft ueber "Name enthaelt diesen Text", weil Godot beim
## Import Punkte aus Node-Namen entfernt ("Armature.RA_26" -> "ArmatureRA_26").
@export_enum("RA", "RB", "RC") var robot_variant: String = "RA"

## Faerbt die Modell-Textur ein (Color.WHITE = Originaltextur unveraendert).
## Praktisch, um RA/RB optisch auseinanderzuhalten.
@export var model_tint: Color = Color(1, 1, 1, 1)

## Das Rig schaut nach -Z (Godot-Standard), dieses Projekt benutzt aber +Z
## als "vorne" (_face_player() rechnet atan2(dir.x, dir.z), die AttackHitbox
## sitzt bei +z). Deshalb 180 Grad Grunddrehung auf dem Modell-Knoten.
@export_range(-180.0, 180.0) var model_yaw_offset_deg: float = 180.0

## Schiebt das Modell in X/Z so, dass die Skelett-Mitte exakt ueber dem
## Ursprung des CharacterBody3D liegt. Die .glb hat alle drei Roboter
## nebeneinander in EINEM Koordinatensystem, dadurch sitzt kein Modell von
## sich aus mittig. Gerechnet wird ueber die Rest-Pose der Knochen, nicht
## ueber die Mesh-AABB — die ist bei geskinnten Meshes die Bind-Pose und
## damit genau um diesen Versatz daneben.
@export var model_auto_center: bool = true

## Zusaetzlich die Fuesse auf die Unterkante der CollisionShape3D setzen.
## Standardmaessig aus, weil der unterste Knochen der Knoechel ist und nicht
## die Sohle — bei Bedarf einschalten und model_ground_bias nachziehen.
@export var model_auto_ground: bool = false
@export var model_ground_bias: float = 0.0

@export_range(4.0, 128.0) var psx_snap_resolution: float = 77.73
@export_range(0.0, 1.0) var psx_vertex_jitter: float = 0.64

## Name der Lauf-Animation im AnimationPlayer der .glb.
## ACHTUNG: Das gelieferte Asset enthaelt exakt EINE Animation, und die heisst
## schlicht "Animation" (1.0 s Lauf-Zyklus). Eine "Attack"-Animation ist NICHT
## enthalten -- der Schlag wird deshalb weiter unten prozedural erzeugt.
@export var locomotion_animation: String = "Animation"

## Bei welcher Laufgeschwindigkeit die Animation mit speed_scale 1.0 laeuft.
## <= 0 nimmt automatisch move_speed.
@export var locomotion_speed_reference: float = 0.0
@export var locomotion_min_speed_scale: float = 0.35
@export var locomotion_max_speed_scale: float = 2.5

## Im Stand die Animation anhalten statt sie auf der Stelle weiterlaufen zu
## lassen. Ohne echte Idle-Animation sieht Einfrieren deutlich besser aus als
## Laufen ohne Vorwaertsbewegung.
@export var freeze_animation_when_idle: bool = true

# --- Prozeduraler Schlag (Ersatz fuer die fehlende Attack-Animation) -------

@export var attack_swing_enabled: bool = true

## Knochen, die beim Schlag rotiert werden. Das Rig heisst z.B.
## "UpperArm.R_8" / "LowerArm.R_7" -- Teil-Treffer genuegen, gesucht wird
## ueber "Knochenname enthaelt diesen Text".
@export var attack_swing_bones: PackedStringArray = PackedStringArray(["UpperArm.R", "LowerArm.R"])

## Drehachse im lokalen Knochenraum. Je nach Bone-Roll kann Vector3(1,0,0)
## oder Vector3(0,0,1) richtig sein -- im Editor kurz durchprobieren.
@export var attack_swing_axis: Vector3 = Vector3(1, 0, 0)

## Ausholen (negativ = nach hinten) und Zuschlagen (positiv = nach vorne).
@export_range(-180.0, 180.0) var attack_windup_angle_deg: float = -55.0
@export_range(-180.0, 180.0) var attack_strike_angle_deg: float = 80.0

## Dauer des eigentlichen Zuschlagens. Sollte <= der Aktivzeit der Hitbox
## (0.2 s) bleiben, damit Treffer und sichtbarer Schlag zusammenfallen.
@export var attack_strike_time: float = 0.12
@export var attack_recover_time: float = 0.25

## Zusaetzliches Vorlehnen des ganzen Modells waehrend des Schlags.
@export_range(0.0, 45.0) var attack_lean_angle_deg: float = 12.0

## Bewusst als Node (nicht Node3D) typisiert: fehlt die .glb im Projekt,
## ersetzt Godot die Instanz durch einen "MissingNode" — ein Cast auf Node3D
## wuerde dann still null liefern und das echte Problem verschlucken.
@onready var character_model: Node = get_node_or_null(NodePath(model_node_name))
@onready var attack_hitbox: Hitbox = get_node_or_null("AttackHitbox")
@onready var telegraph_inner: MeshInstance3D = get_node_or_null("AttackHitbox/TelegraphInner")
@onready var telegraph_outer: MeshInstance3D = get_node_or_null("AttackHitbox/TelegraphOuterRing")
@onready var health: Health = get_node_or_null("Health")
@onready var mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")
@onready var nav_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D")

## Knoten, der beim Tod zusammenschrumpft und den Angriffs-Lean bekommt:
## das .glb-Modell, oder ersatzweise die alte Kapsel.
var _visual_root: Node3D
var _anim_player: AnimationPlayer
var _mesh_materials: Array[ShaderMaterial] = []
## Paare [Skeleton3D, bone_idx] fuer den prozeduralen Schlag.
var _swing_bones: Array = []
var _swing_tween: Tween
var _lean_tween: Tween
var _anim_was_playing: bool = false
## Grunddrehung des Modells, damit der Angriffs-Lean sie nicht ueberschreibt.
var _model_base_rotation: Vector3 = Vector3.ZERO
## +1 oder -1: bei 180 Grad Grunddrehung zeigt die lokale X-Achse rueckwaerts,
## der Lean muesste sonst nach hinten kippen.
var _lean_sign: float = 1.0

var _state: State = State.IDLE
var _player: Node3D
var _attack_timer: float = 0.0
var _is_attacking: bool = false
var _mesh_material: ShaderMaterial
var _base_alpha: float = 1.0
var _last_known_health: float = -1.0
var _alpha_tween: Tween
var _flash_tween: Tween

# BUGFIX: _do_attack() enthaelt mehrere awaits. Stirbt der Gegner mittendrin,
# lief die Coroutine danach auf einem bereits freigegebenen Objekt weiter und
# warf "Attempt to call function on a previously freed instance" in die
# Konsole. Ueber dieses Flag steigt die Coroutine sauber aus.
var _is_dead: bool = false

var _collision_shape_cache: CollisionShape3D
var _warned_missing_collision_shape: bool = false

# Einmalig in _ready() gewuerfelter, instanzspezifischer Tempo-Multiplikator.
var _speed_multiplier: float = 1.0

var _nav_update_timer: float = 0.0
# Wird beim ersten Nutzungsversuch geprueft: existiert ueberhaupt eine
# NavigationRegion3D auf der Map? Ohne die spammt is_target_reachable()
# nur Warnungen und liefert immer false.
var _nav_map_checked: bool = false
var _nav_map_usable: bool = false

func _debug(msg: String) -> void:
	if debug_logging:
		print("EnemyAI DEBUG [%s]: %s" % [display_name, msg])

func _recalculate_jump_velocity() -> void:
	jump_velocity = sqrt(2.0 * max(gravity, 0.0) * max(jump_height, 0.0))

# Wuerfelt den instanzspezifischen Tempo-Multiplikator. Bewusst nur EINMAL
# beim Spawn — ein pro Frame neu gewuerfelter Wert wuerde als Zittern statt
# als Charakter wahrgenommen.
func _roll_speed_multiplier() -> void:
	var v: float = clampf(speed_variance, 0.0, 0.5)
	_speed_multiplier = randf_range(1.0 - v, 1.0 + v)
	_debug("Tempo-Multiplikator gewuerfelt: %.3f (effektiv %.2f m/s)" % [_speed_multiplier, move_speed * _speed_multiplier])

# Effektives Tempo inkl. Slow-Status und individueller Streuung.
func get_effective_move_speed() -> float:
	var slow_factor: float = 1.0 - clamp(status_effects.get_effect_magnitude("slow"), 0.0, 1.0)
	return move_speed * _speed_multiplier * slow_factor

# Aktuelle XZ-Distanz zum Spieler. Die Y-Achse wird bewusst ignoriert:
# Ein Gegner, der 3 Meter unter dem Spieler auf einer Treppe steht, soll
# nicht faelschlich als "ausser Reichweite" gelten.
func _distance_to_player_xz() -> float:
	if _player == null or not is_instance_valid(_player):
		return INF
	var offset: Vector3 = _player.global_position - global_position
	offset.y = 0.0
	return offset.length()

# Prueft, ob der Gegner den Spieler grob anschaut. Ohne diesen Check
# starten Gegner Angriffe waehrend sie sich noch drehen und schlagen
# seitlich vorbei.
#
# Verglichen wird die AKTUELLE rotation.y gegen genau die Ziel-Yaw, die
# _face_player() ansteuert (atan2(dir.x, dir.z)). Dadurch ist der Check
# unabhaengig davon, welche Achse das Projekt als "vorne" definiert —
# siehe die ausfuehrliche Begruendung bei attack_min_facing_dot.
func _is_facing_player() -> bool:
	if attack_min_facing_dot <= -1.0:
		return true
	if _player == null or not is_instance_valid(_player):
		return false

	var to_player: Vector3 = _player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() < 0.01:
		return true
	to_player = to_player.normalized()

	# Exakt dieselbe Formel wie in _face_player().
	var target_yaw: float = atan2(to_player.x, to_player.z)
	var yaw_error: float = absf(angle_difference(rotation.y, target_yaw))

	# Dot-Schwelle in einen maximal erlaubten Winkel umrechnen, damit der
	# Inspector-Wert dieselbe Bedeutung behaelt wie vorher.
	var max_angle: float = acos(clampf(attack_min_facing_dot, -1.0, 1.0))

	if yaw_error > max_angle:
		_debug("Angriff wartet — Blickwinkel %.1f Grad > erlaubte %.1f Grad." % [rad_to_deg(yaw_error), rad_to_deg(max_angle)])
		return false
	return true

# Wird bei JEDEM Charakterwechsel gefeuert (siehe PartyManager) — haelt
# _player aktuell, da der Player-Node beim Wechseln komplett ausgetauscht
# wird (alte Instanz wird entfernt, neue gespawnt).
func _on_active_player_changed(new_player: CharacterBody3D) -> void:
	_player = new_player

# Holt die aktuelle Spieler-Instanz bevorzugt ueber PartyManager (immer
# aktuell), find_child("Player") nur als Fallback, falls PartyManager aus
# irgendeinem Grund noch keine Instanz kennt.
func _refresh_player_reference() -> void:
	if PartyManager.player and is_instance_valid(PartyManager.player):
		_player = PartyManager.player
	else:
		_player = get_tree().get_root().find_child("Player", true, false)
	if _player == null:
		push_warning("EnemyAI: Konnte keinen Node namens 'Player' finden.")

func _ready() -> void:
	add_to_group("enemies")
	_roll_speed_multiplier()
	_refresh_player_reference()
	if not PartyManager.active_player_changed.is_connected(_on_active_player_changed):
		PartyManager.active_player_changed.connect(_on_active_player_changed)

	_setup_slope_stability()

	_zigzag_timer = zigzag_leg_time
	if zigzag_random_phase:
		# Zufaelliger Einstiegspunkt im Takt: sowohl die Phase als auch
		# die Restzeit darin, sonst starten alle gleichzeitig ihr Bein.
		_zigzag_phase_index = randi() % 4
		_zigzag_timer = randf() * (zigzag_pause_time if _zigzag_is_pause() else zigzag_leg_time)

	_debug("_ready(). attack_hitbox=%s | telegraph_inner=%s | telegraph_outer=%s | nav_agent=%s" % [attack_hitbox, telegraph_inner, telegraph_outer, nav_agent])

	var shape_node := _get_collision_shape_node()
	if shape_node == null:
		push_warning("EnemyAI (%s): Keine CollisionShape3D gefunden! Kanten-/Hindernis-Checks laufen mit Fallback-Werten und sind unzuverlaessig." % display_name)

	status_effects = StatusEffectManager.get_or_create(self)
	status_effects.effect_ticked.connect(_on_status_effect_ticked)

	_recalculate_jump_velocity()

	if telegraph_inner:
		telegraph_inner.visible = false
		telegraph_inner.scale = Vector3(0.01, 1.0, 0.01)
	if telegraph_outer:
		telegraph_outer.visible = false

	_setup_visuals()
	_setup_animation()

	if health:
		health.died.connect(_on_died)
		health.health_changed.connect(_on_health_changed)
		_on_health_changed(health.current_health, health.max_health)

## Sucht das sichtbare Modell, blendet die beiden ungenutzten Roboter aus und
## legt auf JEDE Surface ein eigenes PSX-ShaderMaterial.
##
## Warum eigene Materialien: alpha_multiplier (HP-Transparenz) und
## flash_strength (Hit-Flash) sind Shader-Uniforms. Wuerden sich mehrere
## Gegner ein Material teilen, blitzen beim Treffer ALLE gleichzeitig auf.
## Deshalb wird pro Instanz dupliziert bzw. neu gebaut.
func _setup_visuals() -> void:
	var model_root: Node3D = null
	if character_model != null:
		if character_model is Node3D:
			model_root = character_model as Node3D
		else:
			# Godot ersetzt eine Instanz, deren Szene beim Laden fehlte, durch
			# einen MissingNode. Genau dann ist der Gegner unsichtbar.
			push_error("EnemyAI (%s): '%s' ist ein %s statt Node3D. Die .glb unter res://assets/characters/lowpoly_robots.glb fehlt, ist noch nicht importiert oder liegt als OneDrive-Platzhalter (nur online) auf der Platte. Szene NICHT speichern, sonst geht der Knoten verloren!" % [display_name, model_node_name, character_model.get_class()])

	_visual_root = model_root if model_root != null else mesh
	if _visual_root == null:
		push_error("EnemyAI (%s): Kein sichtbares Modell — weder '%s' noch der alte Kapsel-Platzhalter 'MeshInstance3D' sind vorhanden." % [display_name, model_node_name])
		return

	if model_root != null:
		_hide_unused_armatures(model_root)
		_orient_model(model_root)

	var meshes: Array[MeshInstance3D] = []
	_collect_mesh_instances(_visual_root, meshes)
	if meshes.is_empty():
		push_warning("EnemyAI (%s): Unter '%s' liegt keine MeshInstance3D." % [display_name, _visual_root.name])
		return

	for mi: MeshInstance3D in meshes:
		if mi.mesh == null:
			continue

		# Godot berechnet die Culling-Box eines geskinnten Meshes aus der
		# Bind-Pose IN LOKALEN KOORDINATEN und skaliert sie erst dann mit dem
		# Node-Transform hoch. Bei kraeftig hochskalierten Modellen (Colossus:
		# x4) kann das knapp genug daneben liegen, dass die Engine das Mesh
		# aus dem Kamera-Frustum wirft, obwohl es sichtbar im Bild stehen
		# muesste — das Modell "verschwindet" dann je nach Blickwinkel
		# komplett. Ein grosszuegiger Cull-Margin schaltet dieses Wegschneiden
		# effektiv ab; kostet auf so wenigen Gegner-Instanzen nichts spuerbar.
		mi.extra_cull_margin = 16.0

		for surface: int in range(mi.mesh.get_surface_count()):
			var source: Material = mi.get_surface_override_material(surface)
			if source == null:
				source = mi.get_active_material(surface)

			var shader_mat: ShaderMaterial
			if source is ShaderMaterial and (source as ShaderMaterial).shader == PSX_SHADER:
				# Alte Kapsel-Platzhalter: im Editor eingestellte Werte behalten.
				shader_mat = (source as ShaderMaterial).duplicate() as ShaderMaterial
			else:
				# Importiertes .glb-Material: Textur uebernehmen, Rest PSX-isieren.
				shader_mat = ShaderMaterial.new()
				shader_mat.shader = PSX_SHADER
				var tint: Color = model_tint
				if source is BaseMaterial3D:
					var base: BaseMaterial3D = source as BaseMaterial3D
					if base.albedo_texture != null:
						shader_mat.set_shader_parameter("albedo_texture", base.albedo_texture)
					tint = Color(
						base.albedo_color.r * model_tint.r,
						base.albedo_color.g * model_tint.g,
						base.albedo_color.b * model_tint.b,
						base.albedo_color.a * model_tint.a
					)
				shader_mat.set_shader_parameter("albedo_color", tint)
				shader_mat.set_shader_parameter("snap_resolution", psx_snap_resolution)
				shader_mat.set_shader_parameter("vertex_jitter_strength", psx_vertex_jitter)

			shader_mat.set_shader_parameter("flash_strength", 0.0)
			shader_mat.set_shader_parameter("alpha_multiplier", 1.0)
			mi.set_surface_override_material(surface, shader_mat)
			_mesh_materials.append(shader_mat)

	# Rueckwaertskompatibel: aeltere Stellen im Code lesen noch _mesh_material.
	if not _mesh_materials.is_empty():
		_mesh_material = _mesh_materials[0]

	_debug("_setup_visuals(): %d Surface(s) mit PSX-Material bestueckt." % _mesh_materials.size())


## Dreht das Modell in Blickrichtung des Projekts und schiebt es mittig
## ueber den Ursprung des CharacterBody3D.
func _orient_model(model_root: Node3D) -> void:
	model_root.rotation = Vector3(0.0, deg_to_rad(model_yaw_offset_deg), 0.0)
	_model_base_rotation = model_root.rotation
	_lean_sign = -1.0 if cos(deg_to_rad(model_yaw_offset_deg)) < 0.0 else 1.0

	if not model_auto_center and not model_auto_ground:
		return

	var skeleton: Skeleton3D = _find_visible_skeleton(model_root)
	if skeleton == null:
		_debug("_orient_model(): kein sichtbares Skeleton3D — Zentrierung uebersprungen.")
		return

	# Rest-Pose der Knochen per Vorwaerts-Kinematik in den Raum des
	# CharacterBody3D umrechnen. get_bone_rest() + get_bone_parent() sind
	# versionsstabil; get_bone_global_pose() waere zu diesem Zeitpunkt noch
	# nicht zwingend aktualisiert.
	var to_body: Transform3D = global_transform.affine_inverse() * skeleton.global_transform
	var lo: Vector3 = Vector3.INF
	var hi: Vector3 = -Vector3.INF
	for bone_index: int in range(skeleton.get_bone_count()):
		var point: Vector3 = to_body * _rest_global_transform(skeleton, bone_index).origin
		lo = lo.min(point)
		hi = hi.max(point)

	if lo.x > hi.x:
		return

	var shift: Vector3 = Vector3.ZERO
	if model_auto_center:
		shift.x = (lo.x + hi.x) * 0.5
		shift.z = (lo.z + hi.z) * 0.5
	if model_auto_ground:
		var floor_y: float = 0.0
		var shape_node: CollisionShape3D = _get_collision_shape_node()
		if shape_node != null and shape_node.shape is CapsuleShape3D:
			floor_y = shape_node.position.y - (shape_node.shape as CapsuleShape3D).height * 0.5
		shift.y = lo.y - floor_y - model_ground_bias

	model_root.position -= shift
	_debug("_orient_model(): Yaw %.0f Grad, Versatz korrigiert um %s" % [model_yaw_offset_deg, shift])


func _rest_global_transform(skeleton: Skeleton3D, bone_index: int) -> Transform3D:
	var result: Transform3D = skeleton.get_bone_rest(bone_index)
	var parent_index: int = skeleton.get_bone_parent(bone_index)
	while parent_index >= 0:
		result = skeleton.get_bone_rest(parent_index) * result
		parent_index = skeleton.get_bone_parent(parent_index)
	return result


func _find_visible_skeleton(root: Node) -> Skeleton3D:
	for node: Node in _iterate_descendants(root):
		if node is Skeleton3D and (node as Skeleton3D).is_visible_in_tree():
			return node as Skeleton3D
	return null


## Blendet die beiden nicht benoetigten Roboter aus der Sammel-.glb aus.
##
## BUGFIX: Vorher wurde JEDER Knoten mit "Armature" im Namen einzeln per
## Substring gegen robot_variant geprueft. Das setzt voraus, dass Godots
## Namens-Sanitizing beim Import ("Armature.RB_53" -> was auch immer daraus
## wird) genau zu einem der drei geratenen Muster passt. War das bei EINER
## Variante nicht der Fall (z.B. weil Godot Punkte anders behandelt als
## angenommen), blieb deren Node unsichtbar, ohne dass "found == 0" das
## bemerkt haette (die anderen zwei Varianten liefern ja Treffer).
##
## Jetzt zuerst strukturell: die drei Roboter sind im .glb IMMER Geschwister
## unter demselben Elternknoten (garantiert durch die Reihenfolge in der
## Quelldatei: RA, RB, RC). Namensabgleich bleibt die bevorzugte Methode,
## faellt aber auf den Index dieser Geschwisterliste zurueck, wenn der Name
## nicht passt -- das kann nicht mehr an Sanitizing-Details scheitern.
func _hide_unused_armatures(root: Node) -> void:
	var candidates: Array[Node3D] = []
	_collect_armature_roots(root, candidates)

	if candidates.is_empty():
		_debug("_hide_unused_armatures(): keine Armature-Kandidaten gefunden (Modell evtl. schon vereinzelt).")
		return

	var wanted_node: Node3D = null
	for candidate: Node3D in candidates:
		var name_upper: String = String(candidate.name).to_upper()
		if name_upper.contains("ARMATURE" + robot_variant.to_upper()) \
			or name_upper.contains("ARMATURE." + robot_variant.to_upper()) \
			or name_upper.contains("ARMATURE_" + robot_variant.to_upper()):
			wanted_node = candidate
			break

	if wanted_node == null:
		# Namensabgleich erfolglos -> Positions-Fallback ueber die feste
		# Reihenfolge RA=0, RB=1, RC=2 aus der Quelldatei.
		var order: PackedStringArray = ["RA", "RB", "RC"]
		var index: int = order.find(robot_variant.to_upper())
		if index >= 0 and index < candidates.size():
			wanted_node = candidates[index]
			_debug("_hide_unused_armatures(): Namenssuche erfolglos, benutze Geschwister-Index %d als Fallback." % index)

	for candidate: Node3D in candidates:
		candidate.visible = (candidate == wanted_node)

	if wanted_node == null:
		push_warning("EnemyAI (%s): Konnte robot_variant '%s' weder ueber Namen noch Index einem der %d gefundenen Roboter zuordnen — alle sind unsichtbar." % [display_name, robot_variant, candidates.size()])


## Sucht die Ebene im Baum, auf der die Roboter als GESCHWISTER auftauchen
## (jeder Kandidat traegt irgendwo unter sich ein Skeleton3D). Steigt so
## lange durch Einzelkind-Wrapper ab (z.B. "Sketchfab_model" -> "root" ->
## "GLTF_SceneRootNode"), bis eine Ebene mit mehreren Kandidaten gefunden
## wird -- das sind dann RA/RB/RC in ihrer garantierten Quelldatei-Reihenfolge.
func _collect_armature_roots(root: Node, into: Array[Node3D]) -> void:
	var found: Array[Node3D] = []
	for child: Node in root.get_children():
		if child is Node3D and _contains_skeleton(child):
			found.append(child as Node3D)

	if found.size() >= 2:
		into.append_array(found)
		return

	if found.size() == 1:
		_collect_armature_roots(found[0], into)
	else:
		for child: Node in root.get_children():
			_collect_armature_roots(child, into)


func _contains_skeleton(node: Node) -> bool:
	if node is Skeleton3D:
		return true
	for child: Node in node.get_children():
		if _contains_skeleton(child):
			return true
	return false


## Holt den AnimationPlayer aus der .glb, stellt die Lauf-Animation auf Loop
## und merkt sich die Knochen fuer den prozeduralen Schlag.
func _setup_animation() -> void:
	if _visual_root == null:
		return

	for node: Node in _iterate_descendants(_visual_root):
		if node is AnimationPlayer:
			_anim_player = node as AnimationPlayer
			break

	if _anim_player == null:
		_debug("_setup_animation(): kein AnimationPlayer im Modell — Animationen deaktiviert.")
		return

	if not _anim_player.has_animation(locomotion_animation):
		push_warning("EnemyAI (%s): Animation '%s' existiert nicht. Vorhanden: %s" % [display_name, locomotion_animation, ", ".join(_anim_player.get_animation_list())])
		_anim_player = null
		return

	# Importierte glTF-Animationen sind standardmaessig NICHT geloopt.
	var clip: Animation = _anim_player.get_animation(locomotion_animation)
	clip.loop_mode = Animation.LOOP_LINEAR

	_anim_player.play(locomotion_animation)
	# Zufaelliger Startpunkt, sonst laeuft eine ganze Welle im Gleichschritt.
	_anim_player.seek(randf() * clip.length, true)

	if attack_swing_enabled:
		_cache_swing_bones()


func _cache_swing_bones() -> void:
	_swing_bones.clear()
	for node: Node in _iterate_descendants(_visual_root):
		if node is not Skeleton3D:
			continue
		var skeleton: Skeleton3D = node as Skeleton3D
		if not skeleton.is_visible_in_tree():
			continue
		for bone_index: int in range(skeleton.get_bone_count()):
			var bone_name: String = skeleton.get_bone_name(bone_index)
			for pattern: String in attack_swing_bones:
				if bone_name.contains(pattern):
					_swing_bones.append([skeleton, bone_index])
					break

	if _swing_bones.is_empty():
		_debug("_cache_swing_bones(): keine passenden Knochen gefunden — Schlag laeuft nur als Koerper-Lean.")


func _collect_mesh_instances(root: Node, into: Array[MeshInstance3D]) -> void:
	if root is MeshInstance3D:
		into.append(root as MeshInstance3D)
	for child: Node in root.get_children():
		_collect_mesh_instances(child, into)


func _iterate_descendants(root: Node) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in root.get_children():
		out.append(child)
		out.append_array(_iterate_descendants(child))
	return out


## Passt das Abspieltempo der Lauf-Animation an die echte Geschwindigkeit an.
func _update_locomotion_animation() -> void:
	if _anim_player == null or _is_attacking or _is_dead:
		return

	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	var reference: float = locomotion_speed_reference
	if reference <= 0.0:
		reference = maxf(move_speed, 0.001)

	if horizontal_speed < 0.15:
		if freeze_animation_when_idle:
			if _anim_player.is_playing():
				_anim_player.pause()
			return
		_anim_player.speed_scale = locomotion_min_speed_scale
	else:
		_anim_player.speed_scale = clampf(horizontal_speed / reference, locomotion_min_speed_scale, locomotion_max_speed_scale)

	if not _anim_player.is_playing():
		_anim_player.play(locomotion_animation)


# --- Prozeduraler Schlag ---------------------------------------------------
#
# WICHTIG: Die gelieferte .glb enthaelt KEINE Attack-Animation, nur einen
# 1-Sekunden-Laufzyklus. `$CharacterModel/AnimationPlayer.play("Attack")`
# wuerde deshalb nur einen Fehler in die Konsole werfen. Stattdessen wird der
# Arm hier direkt ueber die Bone-Pose animiert und exakt an die bestehenden
# Zeiten von _do_attack() gekoppelt:
#
#   pre_attack_delay  -> nichts
#   attack_windup_time -> _begin_attack_swing()  (Arm holt aus)
#   Hitbox.activate()  -> _strike_attack_swing() (Arm schlaegt durch)
#   Hitbox.deactivate()-> _end_attack_swing()    (zurueck in die Laufanimation)
#
# Der AnimationPlayer wird waehrenddessen pausiert, weil er sonst jeden Frame
# die Bone-Poses ueberschreiben wuerde.

## t = -1.0 (voll ausgeholt) .. 0.0 (Ruhe) .. +1.0 (voll durchgeschlagen)
func _apply_swing(t: float) -> void:
	var axis: Vector3 = attack_swing_axis
	if axis.length_squared() < 0.0001:
		axis = Vector3.RIGHT
	axis = axis.normalized()

	var angle_deg: float = 0.0
	if t < 0.0:
		angle_deg = attack_windup_angle_deg * -t
	else:
		angle_deg = attack_strike_angle_deg * t
	var offset: Quaternion = Quaternion(axis, deg_to_rad(angle_deg))

	for entry: Array in _swing_bones:
		var skeleton: Skeleton3D = entry[0]
		if not is_instance_valid(skeleton):
			continue
		var bone_index: int = entry[1]
		var rest: Quaternion = skeleton.get_bone_rest(bone_index).basis.get_rotation_quaternion()
		skeleton.set_bone_pose_rotation(bone_index, rest * offset)


func _set_lean(angle_deg: float) -> void:
	if _visual_root == null or not is_instance_valid(_visual_root):
		return
	# rotation komplett setzen statt nur .x — sonst wuerde die 180-Grad-
	# Grunddrehung beim ersten Schlag verloren gehen.
	_visual_root.rotation = Vector3(
		deg_to_rad(angle_deg) * _lean_sign,
		_model_base_rotation.y,
		_model_base_rotation.z
	)


func _kill_swing_tweens() -> void:
	if _swing_tween != null and _swing_tween.is_valid():
		_swing_tween.kill()
	if _lean_tween != null and _lean_tween.is_valid():
		_lean_tween.kill()


func _begin_attack_swing() -> void:
	if not attack_swing_enabled or _is_dead:
		return
	if _anim_player != null:
		_anim_was_playing = _anim_player.is_playing()
		_anim_player.pause()

	_kill_swing_tweens()
	if not _swing_bones.is_empty():
		_swing_tween = create_tween()
		_swing_tween.tween_method(_apply_swing, 0.0, -1.0, maxf(attack_windup_time, 0.01)) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if attack_lean_angle_deg > 0.0:
		_lean_tween = create_tween()
		_lean_tween.tween_method(_set_lean, 0.0, -attack_lean_angle_deg * 0.4, maxf(attack_windup_time, 0.01))


func _strike_attack_swing() -> void:
	if not attack_swing_enabled or _is_dead:
		return
	_kill_swing_tweens()
	if not _swing_bones.is_empty():
		_swing_tween = create_tween()
		_swing_tween.tween_method(_apply_swing, -1.0, 1.0, maxf(attack_strike_time, 0.01)) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	if attack_lean_angle_deg > 0.0:
		_lean_tween = create_tween()
		_lean_tween.tween_method(_set_lean, -attack_lean_angle_deg * 0.4, attack_lean_angle_deg, maxf(attack_strike_time, 0.01)) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


## Faehrt Arm und Koerper zurueck in die Ruhelage und uebergibt danach wieder
## an den AnimationPlayer. Wird auch bei Abbruch und Tod aufgerufen, damit der
## Gegner nie in der Schlagpose stehen bleibt.
func _end_attack_swing() -> void:
	_kill_swing_tweens()

	if not _swing_bones.is_empty():
		_swing_tween = create_tween()
		_swing_tween.tween_method(_apply_swing, 1.0, 0.0, maxf(attack_recover_time, 0.01)) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_swing_tween.tween_callback(_resume_locomotion)
	else:
		_resume_locomotion()

	if attack_lean_angle_deg > 0.0:
		_lean_tween = create_tween()
		var current_lean: float = 0.0
		if _visual_root != null and is_instance_valid(_visual_root):
			current_lean = rad_to_deg(_visual_root.rotation.x) * _lean_sign
		_lean_tween.tween_method(_set_lean, current_lean, 0.0, maxf(attack_recover_time, 0.01))


func _resume_locomotion() -> void:
	if _is_dead or _anim_player == null:
		return
	if _anim_was_playing or not freeze_animation_when_idle:
		_anim_player.play(locomotion_animation)


## Haelt den Gegner auf Rampen am Boden.
##
## _physics_process() setzt velocity.y auf dem Boden jeden Frame auf 0. Beim
## Laufen ABWAERTS reisst der Koerper dadurch vom Untergrund ab, sobald der
## Hoehenverlust pro Frame groesser ist als floor_snap_length (Godot-Default
## 0.1): der Gegner faellt, landet, huepft weiter die Rampe hinunter. In
## diesem Zustand kann ein schneller Koerper duenne Geometrie durchschlagen.
## Ein groesserer Snap klebt ihn an der Rampe fest, ohne die Sprunglogik zu
## stoeren - Snapping greift ausschliesslich bei velocity.y <= 0.
##
## floor_max_angle wird ebenfalls angehoben: eine 6 Meter hohe Rampe auf
## einem 20 Meter kurzen Korridor sind bereits ~17 Grad, und am Uebergang zum
## Nachbarraum kommen Kanten dazu. Wird der Grenzwinkel ueberschritten, gilt
## die Rampe fuer die Physik als WAND - der Gegner rutscht dann ab statt zu
## laufen.
func _setup_slope_stability() -> void:
	floor_snap_length = maxf(floor_snap_length, 0.6)
	floor_max_angle = maxf(floor_max_angle, deg_to_rad(55.0))
	floor_stop_on_slope = true
	floor_constant_speed = true
	safe_margin = maxf(safe_margin, 0.02)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y <= 0.0:
		# BUGFIX: Frueher wurde velocity.y auf dem Boden bedingungslos
		# genullt. Damit hat _handle_standing_on_player() seinen
		# Aufwaerts-Kick nie ueberlebt (der Gegner "steht" ja auf dem
		# Spielerkopf = is_on_floor()). Jetzt bleibt ein positiver
		# Y-Impuls erhalten und nur Restfallgeschwindigkeit wird gekappt.
		velocity.y = 0.0

	_attack_timer = max(_attack_timer - delta, 0.0)
	_slide_cooldown = max(_slide_cooldown - delta, 0.0)

	if _player == null or not is_instance_valid(_player):
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		_update_telegraph_ground_position()
		_update_locomotion_animation()
		return

	var distance: float = global_position.distance_to(_player.global_position)
	var previous_state: State = _state

	_update_focus(delta, distance)

	if _focus_lost_timer > 0.0:
		# Abgelenkt: kein Angriff, eigene Laufrichtung. Der Zustand bleibt
		# formal CHASE, damit der Gegner nach dem Aussetzer nahtlos
		# weiterverfolgt statt erst wieder in IDLE zu fallen.
		_state = State.CHASE
		_wander_step(delta)
	else:
		match _state:
			State.IDLE:
				velocity.x = 0.0
				velocity.z = 0.0
				if distance <= detection_range:
					_state = State.CHASE

			State.CHASE:
				if distance <= attack_range:
					_state = State.ATTACK
				elif distance > detection_range * 1.5:
					_state = State.IDLE
				else:
					_move_towards_player(delta)

			State.ATTACK:
				velocity.x = 0.0
				velocity.z = 0.0
				_face_player(delta)
				if distance > attack_range * 1.3 and not _is_attacking:
					_state = State.CHASE
				elif _attack_timer <= 0.0 and not _is_attacking and _is_facing_player():
					_do_attack()

	if _state != previous_state:
		_debug("State-Wechsel: %s -> %s (Distanz %.2f, attack_range %.2f)" % [State.keys()[previous_state], State.keys()[_state], distance, attack_range])
		if _state == State.ATTACK and telegraph_outer:
			telegraph_outer.visible = true
		elif _state != State.ATTACK and telegraph_outer and not _is_attacking:
			telegraph_outer.visible = false

	# Sanfte Separation von anderen Gegnern draufaddieren — verhindert,
	# dass sie sich stapeln/ueberlappen, ohne harte Physik-Pops.
	#
	# WAEHREND EINES ANGRIFFS wird sie stark gedaempft. Siehe die
	# ausfuehrliche Begruendung bei attack_separation_factor: ohne die
	# Daempfung schiebt sich ein ausholender Gegner selbst aus seiner
	# eigenen Reichweite und der Schlag geht ins Leere.
	var separation: Vector3 = _get_separation_velocity()
	if _is_attacking or _state == State.ATTACK:
		separation *= clampf(attack_separation_factor, 0.0, 1.0)
	velocity += separation

	# Knockback-Puffer additiv drauf, NACH der State-Machine-Logik, damit er
	# nicht von velocity.x/z = 0 (IDLE/ATTACK) oder move_toward (CHASE)
	# ueberschrieben wird. Klingt selbststaendig ueber knockback_friction ab.
	velocity.x += _knockback_velocity.x
	velocity.z += _knockback_velocity.z
	_knockback_velocity.x = move_toward(_knockback_velocity.x, 0.0, knockback_friction * delta)
	_knockback_velocity.z = move_toward(_knockback_velocity.z, 0.0, knockback_friction * delta)

	move_and_slide()

	_handle_standing_on_player()

	# Telegraph-Ringe NACH move_and_slide() auf den echten Boden pinnen.
	_update_telegraph_ground_position()

	# Lauf-Animation an die tatsaechlich erreichte Geschwindigkeit koppeln.
	_update_locomotion_animation()

# Erkennt, ob der Gegner auf dem Player-Kopf steht, und verpasst ihm
# einen einmaligen Impuls weg — mit Cooldown, damit move_and_slide()
# den Impuls nicht sofort im naechsten Frame wieder killt.
func _handle_standing_on_player() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	# Cooldown aktiv: Impuls wurde bereits gesetzt, abwarten.
	if _slide_cooldown > 0.0:
		return

	# Waehrend eines laufenden Angriffs KEIN Wegschubser. Der Impuls zeigt
	# per Definition vom Spieler weg und wuerde denselben Effekt erzeugen
	# wie die ungedaempfte Separation: Ausholen, wegrutschen, verfehlen.
	if _is_attacking:
		return

	var to_player_xz: Vector3 = global_position - _player.global_position
	to_player_xz.y = 0.0
	var dist_xz: float = to_player_xz.length()

	# Hoehen-Check: stehen wir signifikant UEBER dem Player?
	var feet_y: float = _get_feet_y()
	var player_y: float = _player.global_position.y
	if feet_y < player_y + player_head_slide_min_height_above_player:
		return

	# Nur wenn wir wirklich direkt drueber sind.
	if dist_xz > 4.0:
		return

	var away: Vector3 = to_player_xz
	if away.length() < 0.01:
		away = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
	away = away.normalized()

	_debug("Auf Player-Kopf erkannt (feet_y=%.2f, dist_xz=%.2f) -> Slide-Impuls." % [feet_y, dist_xz])

	# Impuls direkt ueberschreiben — kein move_toward, kein max().
	velocity.x = away.x * player_head_slide_impulse
	velocity.z = away.z * player_head_slide_impulse
	# Aufwaerts-Kick damit Gravity den Impuls nicht sofort neutralisiert.
	velocity.y = player_head_slide_impulse * 0.8

	# Fuer 0.4s nicht nochmal feuern — laesst den Impuls voll wirken.
	_slide_cooldown = 0.4

func _update_telegraph_ground_position() -> void:
	if not telegraph_ground_snap:
		return
	if telegraph_outer == null and telegraph_inner == null:
		return

	var outer_visible: bool = telegraph_outer != null and telegraph_outer.visible
	var inner_visible: bool = telegraph_inner != null and telegraph_inner.visible
	if not outer_visible and not inner_visible:
		return

	var space_state := get_world_3d().direct_space_state
	var ray_origin: Vector3 = global_position + Vector3.UP * 2.0
	var ray_end: Vector3 = global_position - Vector3.UP * telegraph_ground_raycast_range

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [self]
	query.collision_mask = telegraph_ground_raycast_mask

	var result := space_state.intersect_ray(query)

	var ground_y: float = global_position.y
	if result:
		ground_y = result.position.y

	var target_y: float = ground_y + telegraph_ground_clearance

	if telegraph_outer:
		var p: Vector3 = telegraph_outer.global_position
		p.y = target_y
		telegraph_outer.global_position = p

	if telegraph_inner:
		var p2: Vector3 = telegraph_inner.global_position
		p2.y = target_y
		telegraph_inner.global_position = p2

func _get_separation_velocity() -> Vector3:
	var push: Vector3 = Vector3.ZERO
	if separation_radius <= 0.0 or separation_strength <= 0.0:
		return push
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self or not is_instance_valid(other):
			continue
		var other_3d := other as Node3D
		if other_3d == null:
			continue
		var offset: Vector3 = global_position - other_3d.global_position
		offset.y = 0.0
		var dist: float = offset.length()
		if dist > 0.001 and dist < separation_radius:
			var strength: float = (1.0 - dist / separation_radius) * separation_strength
			push += offset.normalized() * strength
	return push

# Prueft EINMALIG, ob die Navigation-Map ueberhaupt Regionen enthaelt.
# Im Level-Generator-Test fehlte die NavigationRegion3D komplett - dann
# liefert is_target_reachable() dauerhaft false und Godot spammt
# "NavigationAgent3D is not on a navigation map" in die Konsole.
func _is_nav_usable() -> bool:
	if nav_agent == null:
		return false
	if _nav_map_checked:
		return _nav_map_usable
	_nav_map_checked = true
	var map: RID = nav_agent.get_navigation_map()
	_nav_map_usable = map.is_valid() and NavigationServer3D.map_get_regions(map).size() > 0
	if not _nav_map_usable:
		push_warning("EnemyAI (%s): Keine NavigationRegion3D auf der Map - Pathfinding deaktiviert, es greift nur Direkt-Chasing." % display_name)
	return _nav_map_usable

func _move_towards_player(delta: float) -> void:
	var dir: Vector3 = Vector3.ZERO
	var following_nav_path: bool = false

	# --- NavMesh-Pfadverfolgung, FALLS ein gueltiger Pfad existiert ---
	if _is_nav_usable():
		_nav_update_timer -= delta
		if _nav_update_timer <= 0.0:
			_nav_update_timer = max(nav_target_update_interval, 0.05)
			nav_agent.target_position = _player.global_position

		if nav_agent.is_target_reachable():
			var next_point: Vector3 = nav_agent.get_next_path_position()
			var to_next: Vector3 = next_point - global_position
			to_next.y = 0.0
			if to_next.length() > 0.01:
				following_nav_path = true
				dir = to_next.normalized()

	if not following_nav_path:
		dir = (_player.global_position - global_position)
		dir.y = 0.0
		dir = dir.normalized()

	# VOR den Kanten- und Hindernis-Pruefungen ausweichen: die pruefen
	# dir, und geprueft werden muss die Richtung, in die der Gegner
	# tatsaechlich laeuft - sonst testet er den Boden neben seinem Weg.
	if zigzag_enabled and _player != null:
		var zigzag_angle: float = _zigzag_step(delta)
		if _zigzag_holding:
			# Pausenphase: stehen bleiben, aber weiter den Spieler
			# anschauen. Frueher Ausstieg, weil Kanten- und
			# Hindernis-Pruefung fuer einen stehenden Gegner sinnlos sind.
			var hold_x: float = velocity.x - _knockback_velocity.x
			var hold_z: float = velocity.z - _knockback_velocity.z
			velocity.x = move_toward(hold_x, 0.0, zigzag_brake_acceleration * delta)
			velocity.z = move_toward(hold_z, 0.0, zigzag_brake_acceleration * delta)
			_waiting_at_ledge = false
			_face_player(delta)
			return
		dir = dir.rotated(Vector3.UP, zigzag_angle)

	_waiting_at_ledge = false

	# --- Ledge-Logik: NUR relevant ohne gueltigen NavMesh-Pfad ---
	if not following_nav_path and dir.length() > 0.01 and _is_ledge_ahead(dir):
		var jumped_across: bool = can_jump_across_ledges and is_on_floor() and _try_jump_across_ledge(dir)

		if not jumped_across:
			var effective_forward_distance: float = ledge_check_forward_distance
			if ledge_check_scale_with_radius:
				effective_forward_distance = max(ledge_check_forward_distance, _get_body_radius() + ledge_check_radius_margin)

			var drop_depth: float = _measure_drop_depth(dir, effective_forward_distance)
			var feet_y: float = _get_feet_y()
			var player_is_below: bool = _player.global_position.y <= feet_y - ledge_drop_player_below_margin

			var may_drop: bool = ledge_drop_enabled and player_is_below and drop_depth <= max_safe_drop_height

			if not may_drop and ledge_wait_enabled:
				_debug("WARTE AN KANTE (Tiefe %.2f, player_is_below=%s)." % [drop_depth, player_is_below])
				_waiting_at_ledge = true
				velocity.x = 0.0
				velocity.z = 0.0
				_face_player(delta)
				return

	# --- Hindernis-Check: kleine Stufe hochspringen ---
	if can_jump and is_on_floor() and dir.length() > 0.01:
		var required_height: float = _get_required_jump_height(dir)
		if required_height > 0.0:
			velocity.y = sqrt(2.0 * gravity * required_height)

	var effective_speed: float = get_effective_move_speed()

	var target_velocity_x: float = dir.x * effective_speed
	var target_velocity_z: float = dir.z * effective_speed
	# Residual (velocity OHNE den zuletzt aufaddierten Knockback-Anteil) als
	# Basis nehmen, sonst wuerde ein aktiver Knockback hier langsam in die
	# normale Verfolgungsgeschwindigkeit "eingerechnet" statt sauber
	# eigenstaendig abzuklingen.
	var residual_x: float = velocity.x - _knockback_velocity.x
	var residual_z: float = velocity.z - _knockback_velocity.z
	velocity.x = move_toward(residual_x, target_velocity_x, movement_acceleration * delta)
	velocity.z = move_toward(residual_z, target_velocity_z, movement_acceleration * delta)
	_face_player(delta)

## Wuerfelt den Aussetzer aus bzw. zaehlt einen laufenden herunter.
func _update_focus(delta: float, distance: float) -> void:
	if not focus_loss_enabled:
		return

	if _focus_lost_timer > 0.0:
		_focus_lost_timer = maxf(_focus_lost_timer - delta, 0.0)
		return

	# Nicht mitten im Angriff und nicht, solange der Spieler ausser
	# Reichweite ist - sonst "vergisst" ein Gegner den Spieler, den er
	# ohnehin nicht verfolgt.
	if _is_attacking or _state == State.IDLE or distance > detection_range:
		return

	# Poisson: aus einer Rate pro Sekunde eine Chance fuer GENAU diesen
	# Frame machen. Eine feste Chance pro Frame haenge sonst an der
	# Bildrate - bei 144 fps setzten die Gegner mehr als doppelt so oft
	# aus wie bei 60.
	var chance: float = 1.0 - exp(-maxf(focus_loss_chance_per_second, 0.0) * delta)
	if randf() >= chance:
		return

	_focus_lost_timer = randf_range(focus_loss_duration_min, maxf(focus_loss_duration_max, focus_loss_duration_min))
	_wander_direction = _random_ground_direction()
	if telegraph_outer:
		telegraph_outer.visible = false
	_debug("Fokus verloren fuer %.2fs." % _focus_lost_timer)


## Laufen waehrend der Ablenkung: eigene Richtung, gedrosseltes Tempo,
## Blick in die Laufrichtung.
func _wander_step(delta: float) -> void:
	_waiting_at_ledge = false

	# Nicht in Gruben oder von Plattformen laufen - die Kantenpruefung des
	# normalen Verfolgens laeuft hier ja nicht mit.
	if _wander_direction.length_squared() < 0.001 or _is_ledge_ahead(_wander_direction):
		_wander_direction = _random_ground_direction()
		velocity.x = move_toward(velocity.x - _knockback_velocity.x, 0.0, movement_acceleration * delta)
		velocity.z = move_toward(velocity.z - _knockback_velocity.z, 0.0, movement_acceleration * delta)
		return

	var effective_speed: float = get_effective_move_speed() * focus_loss_wander_speed_factor
	var residual_x: float = velocity.x - _knockback_velocity.x
	var residual_z: float = velocity.z - _knockback_velocity.z
	velocity.x = move_toward(residual_x, _wander_direction.x * effective_speed, movement_acceleration * delta)
	velocity.z = move_toward(residual_z, _wander_direction.z * effective_speed, movement_acceleration * delta)

	var target_rotation: float = atan2(_wander_direction.x, _wander_direction.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * 6.0)


func _random_ground_direction() -> Vector3:
	var angle: float = randf() * TAU
	return Vector3(sin(angle), 0.0, cos(angle))


## Schaltet den Zickzack-Takt weiter und liefert den Ausweichwinkel des
## aktuellen Beins. Setzt nebenbei _zigzag_holding, wenn gerade eine
## Pausenphase laeuft.
##
## Die Blickrichtung bleibt unberuehrt (_face_player laeuft weiter auf den
## Spieler) - der Gegner schaut einen also an, waehrend er seitlich
## versetzt naeher kommt oder kurz einfriert.
func _zigzag_step(delta: float) -> float:
	# Nah am Ziel: kein Ausschlag, keine Pause. Sonst bliebe der Gegner
	# direkt vor dem Spieler stehen, statt in attack_range zu gehen.
	var distance: float = global_position.distance_to(_player.global_position)
	var span: float = maxf(zigzag_fade_distance - zigzag_min_distance, 0.01)
	var amount: float = clampf((distance - zigzag_min_distance) / span, 0.0, 1.0)
	if amount <= 0.0:
		_zigzag_holding = false
		return 0.0

	_zigzag_timer -= delta
	if _zigzag_timer <= 0.0:
		_zigzag_phase_index = (_zigzag_phase_index + 1) % 4
		_zigzag_timer = zigzag_pause_time if _zigzag_is_pause() else zigzag_leg_time

	_zigzag_holding = _zigzag_is_pause() and amount >= zigzag_pause_min_amount
	if _zigzag_holding:
		return 0.0

	# Phase 0 schlaegt nach rechts aus, Phase 2 nach links.
	var side: float = 1.0 if _zigzag_phase_index == 0 else -1.0
	return deg_to_rad(zigzag_angle_degrees) * side * amount


func _zigzag_is_pause() -> bool:
	return (_zigzag_phase_index % 2) == 1


func _measure_drop_depth(dir: Vector3, effective_forward_distance: float) -> float:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()
	var check_pos: Vector3 = Vector3(global_position.x, feet_y, global_position.z) + dir * effective_forward_distance + Vector3(0, 0.5, 0)
	var ray_end: Vector3 = check_pos - Vector3(0, ledge_drop_probe_distance, 0)

	var query := PhysicsRayQueryParameters3D.create(check_pos, ray_end)
	query.exclude = [self]
	query.collision_mask = ground_raycast_mask

	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return INF

	var drop_y: float = result.position.y
	return feet_y - drop_y

func _get_collision_shape_node() -> CollisionShape3D:
	if _collision_shape_cache and is_instance_valid(_collision_shape_cache):
		return _collision_shape_cache

	var direct := get_node_or_null("CollisionShape3D")
	if direct and direct is CollisionShape3D:
		_collision_shape_cache = direct
		return _collision_shape_cache

	for child in get_children():
		if child is CollisionShape3D:
			if not _warned_missing_collision_shape:
				_debug("Kein Kind namens 'CollisionShape3D' — nutze stattdessen '%s'." % child.get_path())
				_warned_missing_collision_shape = true
			_collision_shape_cache = child
			return _collision_shape_cache

	if not _warned_missing_collision_shape:
		push_warning("EnemyAI (%s): Konnte KEINE CollisionShape3D unter den direkten Kindern finden." % display_name)
		_warned_missing_collision_shape = true
	return null

func _get_feet_y() -> float:
	var collision_shape := _get_collision_shape_node()
	if collision_shape and collision_shape.shape:
		var shape := collision_shape.shape
		var y_scale: float = collision_shape.global_transform.basis.y.length()
		var half_height: float = 0.0
		if shape is CapsuleShape3D:
			half_height = shape.height * 0.5 * y_scale
		elif shape is BoxShape3D:
			half_height = shape.size.y * 0.5 * y_scale
		elif shape is SphereShape3D:
			half_height = shape.radius * y_scale
		return collision_shape.global_position.y - half_height
	return global_position.y

func _get_body_radius() -> float:
	var collision_shape := _get_collision_shape_node()
	if collision_shape and collision_shape.shape:
		var shape := collision_shape.shape
		var xz_scale: float = collision_shape.global_transform.basis.x.length()
		if shape is CapsuleShape3D:
			return shape.radius * xz_scale
		elif shape is BoxShape3D:
			return max(shape.size.x, shape.size.z) * 0.5 * xz_scale
		elif shape is SphereShape3D:
			return shape.radius * xz_scale
	return 0.5

func _get_required_jump_height(dir: Vector3) -> float:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()

	var origin_low: Vector3 = Vector3(global_position.x, feet_y + obstacle_check_low_height, global_position.z)
	var end_low: Vector3 = origin_low + dir * obstacle_check_distance
	var query_low := PhysicsRayQueryParameters3D.create(origin_low, end_low)
	query_low.exclude = [self]
	query_low.collision_mask = ground_raycast_mask
	var result_low := space_state.intersect_ray(query_low)
	if result_low.is_empty():
		return -1.0

	var obstacle_clear_height: float = jump_height
	var found_clear_height: bool = false
	var steps: int = 8
	for i in range(1, steps + 1):
		var h: float = obstacle_check_low_height + (jump_height - obstacle_check_low_height) * float(i) / float(steps)
		var origin: Vector3 = Vector3(global_position.x, feet_y + h, global_position.z)
		var end: Vector3 = origin + dir * obstacle_check_distance
		var query := PhysicsRayQueryParameters3D.create(origin, end)
		query.exclude = [self]
		query.collision_mask = ground_raycast_mask
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			obstacle_clear_height = h
			found_clear_height = true
			break

	if not found_clear_height:
		return -1.0

	return min(obstacle_clear_height + obstacle_jump_margin, jump_height)

func _is_ledge_ahead(dir: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()

	var effective_forward_distance: float = ledge_check_forward_distance
	if ledge_check_scale_with_radius:
		var body_radius: float = _get_body_radius()
		effective_forward_distance = max(ledge_check_forward_distance, body_radius + ledge_check_radius_margin)

	var offsets: Array[Vector3] = [Vector3.ZERO]
	if ledge_check_lateral_samples:
		var lateral_dir: Vector3 = Vector3(-dir.z, 0.0, dir.x)
		var lateral_offset: float = max(_get_body_radius() * 0.5, 0.3)
		offsets.append(lateral_dir * lateral_offset)
		offsets.append(-lateral_dir * lateral_offset)

	for offset in offsets:
		var check_pos: Vector3 = Vector3(global_position.x, feet_y, global_position.z) + dir * effective_forward_distance + offset + Vector3(0, 0.5, 0)
		var ray_end: Vector3 = check_pos - Vector3(0, ledge_check_drop_distance, 0)

		var query := PhysicsRayQueryParameters3D.create(check_pos, ray_end)
		query.exclude = [self]
		query.collision_mask = ground_raycast_mask

		var result := space_state.intersect_ray(query)
		if not result.is_empty():
			return false

	return true

func _try_jump_across_ledge(dir: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()
	var steps: int = 6
	for i in range(1, steps + 1):
		var t: float = jump_across_max_gap * float(i) / float(steps)
		var probe: Vector3 = Vector3(global_position.x, feet_y, global_position.z) + dir * t + Vector3(0, 0.5, 0)
		var probe_end: Vector3 = probe - Vector3(0, ledge_check_drop_distance, 0)
		var query := PhysicsRayQueryParameters3D.create(probe, probe_end)
		query.exclude = [self]
		query.collision_mask = ground_raycast_mask
		var result := space_state.intersect_ray(query)
		if not result.is_empty():
			velocity.y = jump_velocity
			return true
	return false

func _face_player(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var dir: Vector3 = (_player.global_position - global_position)
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	dir = dir.normalized()
	var target_rotation: float = atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * 6.0)

func _do_attack() -> void:
	_is_attacking = true
	_attack_timer = attack_cooldown
	_debug("_do_attack() gestartet. pre_attack_delay=%.2fs" % pre_attack_delay)

	if pre_attack_delay > 0.0:
		await get_tree().create_timer(pre_attack_delay).timeout
	if _is_dead or not is_instance_valid(self):
		return

	if telegraph_inner:
		telegraph_inner.visible = true
		telegraph_inner.scale = Vector3(0.01, 1.0, 0.01)
		var grow_tween := create_tween()
		grow_tween.tween_property(telegraph_inner, "scale", Vector3.ONE, attack_windup_time)\
			.set_trans(Tween.TRANS_LINEAR)

	# Arm holt waehrend des Windups sichtbar aus.
	_begin_attack_swing()

	if attack_windup_time > 0.0:
		await get_tree().create_timer(attack_windup_time).timeout
	if _is_dead or not is_instance_valid(self):
		return

	if telegraph_inner:
		telegraph_inner.visible = false

	# --- Freigabe-Check: steht der Spieler UEBERHAUPT noch in Reichweite? ---
	# Ohne diesen Check wird die Hitbox auch dann aktiviert, wenn der Spieler
	# waehrend pre_attack_delay + attack_windup_time laengst weggelaufen ist.
	var commit_range: float = attack_range * maxf(attack_commit_range_multiplier, 0.1)
	if _distance_to_player_xz() > commit_range:
		_debug("Angriff ABGEBROCHEN — Spieler ausser Reichweite (%.2f > %.2f)." % [_distance_to_player_xz(), commit_range])
		_abort_attack()
		return

	# Treffer-Fenster und sichtbarer Schlag starten im GLEICHEN Frame.
	_strike_attack_swing()

	if attack_hitbox:
		attack_hitbox.activate()
		await get_tree().create_timer(0.2).timeout
		if _is_dead or not is_instance_valid(self):
			return
		attack_hitbox.deactivate()
	else:
		push_warning("EnemyAI (%s): attack_hitbox ist null — Node 'AttackHitbox' fehlt." % display_name)
		await get_tree().create_timer(maxf(attack_strike_time, 0.05)).timeout
		if _is_dead or not is_instance_valid(self):
			return

	_end_attack_swing()
	_is_attacking = false

	if _state != State.ATTACK and telegraph_outer:
		telegraph_outer.visible = false

# --- Transparenz nach HP + Hit-Flash ---

func _on_health_changed(current: float, max_hp: float) -> void:
	var percent: float = clamp(current / max(max_hp, 0.001), 0.0, 1.0)
	_base_alpha = lerp(min_alpha_at_zero_hp, 1.0, percent)
	_set_mesh_alpha(_base_alpha)

	if _last_known_health >= 0.0 and current < _last_known_health:
		_play_hit_flash()
	_last_known_health = current

func _set_mesh_alpha(value: float) -> void:
	for material: ShaderMaterial in _mesh_materials:
		material.set_shader_parameter("alpha_multiplier", value)

func _play_hit_flash() -> void:
	if _mesh_materials.is_empty():
		return

	if _alpha_tween and _alpha_tween.is_valid():
		_alpha_tween.kill()
	_alpha_tween = create_tween()
	_alpha_tween.tween_method(_set_mesh_alpha, _base_alpha, hit_flash_alpha, hit_flash_duration * 0.5)
	_alpha_tween.tween_method(_set_mesh_alpha, hit_flash_alpha, _base_alpha, hit_flash_duration * 0.5)

	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_method(_set_flash_strength, 0.0, hit_color_flash_strength, hit_color_flash_duration * 0.4)
	_flash_tween.tween_method(_set_flash_strength, hit_color_flash_strength, 0.0, hit_color_flash_duration * 0.6)

func _set_flash_strength(value: float) -> void:
	for material: ShaderMaterial in _mesh_materials:
		material.set_shader_parameter("flash_strength", value)

# --- Tod ---

func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	set_physics_process(false)
	# Kollision sofort abschalten, damit die sterbende Instanz waehrend der
	# Death-Animation weder den Spieler blockiert noch von Hitboxen
	# nochmal getroffen wird.
	collision_layer = 0
	collision_mask = 0
	remove_from_group("enemies")

	if attack_hitbox:
		attack_hitbox.deactivate()
	if telegraph_inner:
		telegraph_inner.visible = false
	if telegraph_outer:
		telegraph_outer.visible = false

	# Laufende Schlag-Tweens abbrechen, sonst schreiben sie waehrend der
	# Todes-Animation weiter in Bone-Posen eines sterbenden Objekts.
	_kill_swing_tweens()
	if _anim_player != null:
		_anim_player.pause()

	if _visual_root != null and is_instance_valid(_visual_root):
		var tween := create_tween()
		tween.tween_property(_visual_root, "scale", Vector3.ZERO, 0.4)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await tween.finished

	queue_free()
