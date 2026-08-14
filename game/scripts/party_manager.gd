
extends Node

# AUTOLOAD — Name: PartyManager
# Projekt -> Projekteinstellungen -> Autoload -> res://scripts/party_manager.gd
#
# Verwaltet die Party (bis zu 4 CharacterData), wer aktiv ist, und deren
# HP-Stand. Es existiert IMMER nur EIN aktiver CharacterBody3D im Level —
# beim Wechsel wird die aktuelle Charakter-Instanz entfernt und die neue
# (mit ihrem eigenen Combat-Script/eigenen Fähigkeiten) an derselben
# Stelle neu instanziert. Position, Kamera-Ausrichtung und HP werden dabei
# übernommen.
#
# Switch-Cooldown: Sobald man von einem Charakter WEGwechselt, bekommt
# GENAU DIESER Charakter (nicht der neu aktivierte) einen Cooldown von
# SWITCH_COOLDOWN_DURATION Sekunden, bevor man wieder zu ihm wechseln kann.
#
# ============================================================================
# BUGFIX: "Restart-Button und [R] gehen nicht"
# ============================================================================
# ROOT CAUSE (die eigentliche Ursache, nicht der Button):
# Dieses Autoload UEBERLEBT get_tree().reload_current_scene(). Die Szene
# darunter wird komplett abgebaut - inklusive der Spieler-Instanz, auf die
# "player" zeigt. Ein freigegebenes Object wird in GDScript aber NICHT
# automatisch auf null gesetzt: die Variable haelt weiter den alten Zeiger.
#
# Damit ist
#     player == null          ->  FALSE  (der Zeiger ist ja belegt)
#     is_instance_valid(player) ->  false  (das Objekt ist aber tot)
#
# Der komplette Spawn-Pfad haing an der ERSTEN Form:
#   register_spawn_point():  if player == null and not party.is_empty()
#   setup_party():           if player == null and _spawn_parent != null
#   _spawn_active_character(): if player != null: return
#
# Nach JEDEM Neustart hielt PartyManager also eine Leiche, hielt sich fuer
# "schon bespielt" und spawnte keinen neuen Charakter. Das Level wurde
# korrekt neu generiert - es stand nur nie jemand drin. Von aussen sieht
# genau das aus wie "der Restart-Button tut nichts": Bild baut sich neu
# auf, aber man kann sich nicht bewegen.
#
# Derselbe Mechanismus traf _spawn_parent und _player_health.
#
# FIX: JEDE Lebend-Pruefung laeuft ab jetzt ueber has_player() bzw.
# is_instance_valid(). Zusaetzlich raeumt notify_scene_reset() vor einem
# Szenenwechsel bewusst auf - siehe run_restart.gd, das diese Funktion als
# einziger Neustart-Pfad aufruft.

signal party_changed
signal active_character_changed(index: int)
signal member_health_changed(index: int, current: float, max_hp: float)
## Feuert, wenn der LETZTE verbleibende Charakter der Party auf 0 HP faellt -
## also erst, wenn KEIN Last-Stand-Uebernahme (siehe _on_player_health_died())
## mehr moeglich ist. Das ist das eigentliche Game-Over-Signal; death_screen.gd
## haengt sich hieran statt an das Health.died des jeweils aktiven Charakters.
signal party_wiped
# Wird JEDES MAL gefeuert, wenn die aktive Spieler-Instanz ausgetauscht
# wurde (erstes Spawnen UND jeder Charakterwechsel). Systeme, die sich
# den Player-Node merken (HUD, Minimap, ...), MÜSSEN darauf reagieren und
# ihre Referenz erneuern, statt ihn nur einmal zu suchen.
signal active_player_changed(player: CharacterBody3D)

const MAX_PARTY_SIZE: int = 4
const PLAYER_NODE_NAME: String = "Player"
const PLAYER_GROUP: String = "player"

# Wie lange ein Charakter gesperrt bleibt, NACHDEM man von ihm weggewechselt
# ist (nicht: nachdem man ihn ausgewählt hat).
const SWITCH_COOLDOWN_DURATION: float = 10.0

## Last-Stand-System: stirbt der aktive Charakter und lebt noch mindestens
## ein weiteres Party-Mitglied, uebernimmt das automatisch. Als Strafe fuer
## den Tod wird die HP der GESAMTEN restlichen Party auf hoechstens diesen
## Anteil ihrer jeweiligen Maximal-HP gedeckelt (siehe
## _on_player_health_died()) - nicht nur die des Nachrueckers.
const LAST_STAND_HP_FRACTION: float = 0.20

## Der Nachruecker bei einer Last-Stand-Uebernahme bekommt kurz Schonzeit:
## ohne das kann derselbe Hitbox-Treffer, der gerade den vorigen Charakter
## umgebracht hat, im selben Atemzug auch noch den frisch eingewechselten
## erwischen - der Spieler haette keine Chance, zu reagieren.
const SWITCH_INVULN_DURATION: float = 2.0
## Dauer eines vollen Blink-Zyklus (hell -> dunkel). Kleiner = schnelleres
## Flackern. Muss SWITCH_INVULN_DURATION nicht restlos teilen - der letzte
## Zyklus wird beim Ablauf der Unverwundbarkeit einfach sauber beendet.
const SWITCH_BLINK_INTERVAL: float = 0.12
const SWITCH_BLINK_COLOR: Color = Color(1.0, 1.0, 1.0)
const SWITCH_BLINK_STRENGTH: float = 0.85

var party: Array[CharacterData] = []

var _current_health: Array[float] = []
var _max_health: Array[float] = []
# Verbleibende Cooldown-Sekunden pro Party-Index, 0.0 = bereit.
var _switch_cooldowns: Array[float] = []
var _active_index: int = 0

var player: CharacterBody3D = null
var _player_health: Health = null

var _spawn_parent: Node = null
var _spawn_transform: Transform3D = Transform3D.IDENTITY

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## Einzige erlaubte Lebend-Pruefung fuer "player".
##
## "player == null" reicht NICHT: nach reload_current_scene() ist die
## Instanz freigegeben, die Variable aber weiterhin belegt. Siehe den
## ausfuehrlichen Root-Cause-Block im Dateikopf.
func has_player() -> bool:
	return player != null and is_instance_valid(player)


## Vor einem Szenenwechsel aufzurufen (run_restart.gd). Wirft alle
## Referenzen auf Nodes weg, die den Wechsel nicht ueberleben.
##
## Ohne diesen Aufruf wuerde has_player() den Fehler zwar trotzdem
## abfangen - aber erst NACHDEM die tote Instanz einen Frame lang in
## Signalen und Suchlaeufen mitgeschleift wurde. Sauber ist, den Zustand
## dort zu leeren, wo der Wechsel ausgeloest wird.
func notify_scene_reset() -> void:
	if _player_health != null and is_instance_valid(_player_health):
		if _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.disconnect(_on_player_health_changed)
		if _player_health.died.is_connected(_on_player_health_died):
			_player_health.died.disconnect(_on_player_health_died)
	player = null
	_player_health = null
	_spawn_parent = null
	_spawn_transform = Transform3D.IDENTITY
	# Die Cooldowns gehoeren zum alten Run und duerfen den neuen nicht
	# blockieren. Party/HP setzt PartySetup._ready() im neuen Level
	# ohnehin komplett neu (setup_party).
	for i: int in range(_switch_cooldowns.size()):
		_switch_cooldowns[i] = 0.0

func _process(delta: float) -> void:
	for i: int in range(_switch_cooldowns.size()):
		if _switch_cooldowns[i] > 0.0:
			_switch_cooldowns[i] = max(_switch_cooldowns[i] - delta, 0.0)

# BUGFIX: Entfernt jede Skalierung/Scherung aus einer Spawn-Transform und
# behaelt nur Position + Yaw. Ein Spawn-Marker, der als Kind eines
# skalierten Nodes haengt (z.B. ein hochskalierter RoomRoot im
# Level-Generator), liefert sonst eine Basis MIT Skalierungsfaktor - und
# die landete vorher ungefiltert auf dem Spieler-CharacterBody3D. Ergebnis:
# ein 2.5x zu grosser Spieler, wodurch alle Gegner falsch dimensioniert
# wirkten. Diese Funktion ist die letzte Verteidigungslinie dagegen, egal
# welches Level/Script die Transform liefert.
func _sanitize_spawn_transform(source: Transform3D) -> Transform3D:
	var yaw: float = source.basis.get_euler().y
	var basis := Basis.IDENTITY.rotated(Vector3.UP, yaw)
	return Transform3D(basis, source.origin)

# Wird vom Level (ueber PartySetup) oder spaeter vom Home-Screen aufgerufen.
func setup_party(members: Array[CharacterData]) -> void:
	party.clear()
	_current_health.clear()
	_max_health.clear()
	_switch_cooldowns.clear()

	for i: int in range(min(members.size(), MAX_PARTY_SIZE)):
		var data: CharacterData = members[i]
		if data == null:
			continue
		party.append(data)
		_max_health.append(data.max_health)
		_current_health.append(data.max_health)
		_switch_cooldowns.append(0.0)

	_active_index = 0
	party_changed.emit()

	# Falls bereits ein Spawn-Punkt registriert ist (Level war schneller
	# bereit als PartySetup), aber noch kein Spieler existiert, jetzt spawnen.
	#
	# WICHTIG: deferred, nicht direkt! setup_party() kann selbst mitten in
	# einer fremden Ready-Kaskade laufen (z.B. wenn PartySetup._ready() im
	# selben Frame läuft wie ein dynamisch instanziertes Level), und
	# _spawn_active_character() haengt am Ende einen Node per add_child()
	# in den Baum - das schlaegt fehl, wenn der Zielparent gerade selbst
	# "busy" (blocked) ist, weil ER noch seine eigenen Kinder aufbaut.
	if not has_player() and _spawn_parent != null and is_instance_valid(_spawn_parent):
		call_deferred("_spawn_active_character", _spawn_transform)


## Haengt EINEN Charakter an die BESTEHENDE Party an, ohne sie (wie
## setup_party()) komplett zu ersetzen - fuer scripts/character_pedestal.gd
## (Tutorial-Modus, siehe level_generator.gd::generate_tutorial_stage()),
## das die Party schrittweise von 1 auf 4 Mitglieder waechst, waehrend
## bereits ein Charakter aktiv gespielt wird. Ruehrt party/switch_to()/
## setup_party() selbst nicht an, ist also fuer den normalen Spielfluss (der weiterhin
## ausschliesslich setup_party() nutzt) folgenlos.
##
## hud.gd::_refresh_party() reagiert bereits auf party_changed und baut keine
## eigenen Slot-Nodes, sondern befuellt nur bereits vorhandene (bis zu 5,
## siehe SLOT_COUNT dort) - ein neu angehaengtes Mitglied taucht dadurch
## automatisch im HUD auf, ohne dass hud.gd etwas davon wissen muss.
func add_party_member(data: CharacterData) -> void:
	if data == null or party.size() >= MAX_PARTY_SIZE:
		return
	party.append(data)
	_max_health.append(data.max_health)
	_current_health.append(data.max_health)
	_switch_cooldowns.append(0.0)
	party_changed.emit()

# Wird von einem PlayerSpawnPoint-Marker3D im Level aufgerufen (siehe
# scripts/player_spawn_point.gd). Läuft typischerweise SYNCHRON innerhalb
# der Ready-Kaskade des Levels/Raums, in dem der Marker liegt - deshalb
# NIEMALS hier direkt add_child() durchziehen, sondern immer deferren.
func register_spawn_point(parent: Node, at_transform: Transform3D) -> void:
	_spawn_parent = parent
	_spawn_transform = _sanitize_spawn_transform(at_transform)
	if not has_player() and not party.is_empty():
		call_deferred("_spawn_active_character", _spawn_transform)

func _spawn_active_character(at_transform: Transform3D) -> void:
	# Kann inzwischen (durch den einen Frame Verzoegerung via call_deferred)
	# ueberholt worden sein - z.B. wenn zwischenzeitlich schon jemand
	# anderes gespawnt hat. Doppel-Spawn verhindern.
	#
	# has_player() statt "player != null": nach einem Szenenwechsel steht
	# hier sonst eine Leiche und blockiert den Neu-Spawn dauerhaft.
	if has_player():
		return

	# Zeiger auf eine eventuelle Leiche aus dem alten Run bedingungslos
	# wegwerfen, bevor eine neue Instanz gebaut wird. Bewusst OHNE
	# vorherigen "!= null"-Vergleich: ein Vergleich mit einem bereits
	# freigegebenen Object ist genau die Operation, die in Godot 4 je nach
	# Build eine "Attempted to access a freed object"-Meldung erzeugt.
	player = null
	_player_health = null

	var data: CharacterData = get_active_data()
	if data == null or data.player_scene == null:
		push_warning("PartyManager: Aktiver Charakter '%s' hat keine player_scene zugewiesen." % (data.character_name if data else "?"))
		return
	if _spawn_parent == null or not is_instance_valid(_spawn_parent):
		push_warning("PartyManager: Kein gueltiger Spawn-Parent registriert (PlayerSpawnPoint fehlt im Level).")
		return

	var instance: CharacterBody3D = data.player_scene.instantiate()
	instance.name = PLAYER_NODE_NAME
	instance.add_to_group(PLAYER_GROUP)
	_spawn_parent.add_child(instance)
	# IMMER sanitisiert setzen - siehe _sanitize_spawn_transform().
	instance.global_transform = _sanitize_spawn_transform(at_transform)
	instance.scale = Vector3.ONE

	player = instance
	_connect_player_health()
	_apply_active_health_to_player()

	# Markiert fuers Hauptmenue, dass "Fortsetzen" jetzt sinnvoll waere
	# (siehe GameStats.has_live_run-Kommentar in game_stats.gd). Steht hier
	# und nicht in setup_party(): DAS hier ist der Punkt, an dem tatsaechlich
	# eine lebende Spieler-Instanz in der Welt existiert.
	GameStats.has_live_run = true

	active_player_changed.emit(player)

func _connect_player_health() -> void:
	if not has_player():
		return
	var h := player.find_child("Health", true, false)
	if h and h is Health:
		_player_health = h
		if not _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.connect(_on_player_health_changed)
		# Last-Stand-Uebernahme: siehe _on_player_health_died().
		if not _player_health.died.is_connected(_on_player_health_died):
			_player_health.died.connect(_on_player_health_died)

func _on_player_health_changed(current: float, max_hp: float) -> void:
	if _active_index < 0 or _active_index >= _current_health.size():
		return
	_current_health[_active_index] = current
	_max_health[_active_index] = max_hp
	member_health_changed.emit(_active_index, current, max_hp)

func _apply_active_health_to_player() -> void:
	if _player_health == null or not is_instance_valid(_player_health):
		return
	if _active_index >= _max_health.size():
		return
	_player_health.max_health = _max_health[_active_index]
	_player_health.current_health = _current_health[_active_index]
	_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)


# ============================================================================
# Last-Stand: Charakterwechsel bei 0 HP statt sofortigem Game Over
# ============================================================================
## Der aktive Charakter ist gerade gestorben (Health.died des aktuell
## gebundenen player). Lebt noch ein anderes Party-Mitglied, uebernimmt DAS
## automatisch. Erst wenn niemand mehr uebrig ist, feuert party_wiped - DAS
## ist das eigentliche Game-Over-Signal, das death_screen.gd jetzt
## abonniert, statt direkt am Health.died jedes einzelnen Charakters zu
## haengen.
##
## STRAFE FUER DEN TOD: trifft NICHT nur den uebernehmenden Charakter,
## sondern die GESAMTE restliche (noch lebende) Party wird auf hoechstens
## LAST_STAND_HP_FRACTION ihrer Maximal-HP gedeckelt - ein Charaktertod soll
## das ganze Team schwaechen, nicht nur einen Nachruecker mit frischer HP
## belohnen.
func _on_player_health_died() -> void:
	if _active_index >= 0 and _active_index < _current_health.size():
		_current_health[_active_index] = 0.0
		member_health_changed.emit(_active_index, 0.0, _max_health[_active_index] if _active_index < _max_health.size() else 1.0)

	var next_index: int = _find_next_alive(_active_index)
	if next_index == -1:
		party_wiped.emit()
		return

	for i: int in range(party.size()):
		if i == _active_index or not is_member_alive(i):
			continue  # gerade gestorben (HP bleibt 0) oder ohnehin schon tot
		var capped: float = minf(_current_health[i], _max_health[i] * LAST_STAND_HP_FRACTION)
		if not is_equal_approx(capped, _current_health[i]):
			_current_health[i] = capped
			member_health_changed.emit(i, capped, _max_health[i])

	_force_switch_to_survivor(next_index)


## Naechstes lebendes Party-Mitglied ab exclude_index, im Kreis gesucht -
## damit die Reihenfolge (1, 2, 3, 4, 1, ...) unabhaengig davon ist, WELCHER
## Index gerade gestorben ist. -1, wenn niemand mehr lebt.
func _find_next_alive(exclude_index: int) -> int:
	for offset: int in range(1, party.size()):
		var idx: int = (exclude_index + offset) % party.size()
		if is_member_alive(idx):
			return idx
	return -1


## Wie switch_to(), aber OHNE Cooldown-Sperre und ohne dass irgendjemand
## einen Cooldown bekommt: das ist eine erzwungene Rettung im letzten Moment,
## keine freiwillige taktische Wahl, die man missbrauchen koennte.
func _force_switch_to_survivor(index: int) -> void:
	if not has_player():
		_active_index = index
		active_character_changed.emit(index)
		return

	var carried_transform: Transform3D = _sanitize_spawn_transform(player.global_transform)
	var carried_camera_yaw: float = 0.0
	var carried_camera_pitch: float = 0.0
	var old_camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
	var old_spring_arm: SpringArm3D = player.get_node_or_null("CameraPivot/SpringArm3D")
	if old_camera_pivot:
		carried_camera_yaw = old_camera_pivot.rotation.y
	if old_spring_arm:
		carried_camera_pitch = old_spring_arm.rotation.x

	if _player_health != null and is_instance_valid(_player_health):
		if _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.disconnect(_on_player_health_changed)
		if _player_health.died.is_connected(_on_player_health_died):
			_player_health.died.disconnect(_on_player_health_died)

	_deactivate_old_player(player)
	player.queue_free()
	player = null
	_player_health = null

	_active_index = index
	_spawn_active_character(carried_transform)

	if has_player():
		var new_camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
		var new_spring_arm: SpringArm3D = player.get_node_or_null("CameraPivot/SpringArm3D")
		if new_camera_pivot:
			new_camera_pivot.rotation.y = carried_camera_yaw
		if new_spring_arm:
			new_spring_arm.rotation.x = carried_camera_pitch

	# Schonzeit fuer den Nachruecker - siehe SWITCH_INVULN_DURATION-Kommentar.
	if _player_health != null and is_instance_valid(_player_health):
		_player_health.set_invulnerable(SWITCH_INVULN_DURATION)
	_play_switch_invuln_blink(SWITCH_INVULN_DURATION)

	active_character_changed.emit(index)


# Schaltet Kollision UND Processing der alten Instanz SOFORT ab, statt
# darauf zu warten, dass queue_free() sie entfernt (das passiert erst am
# Frame-Ende). Ohne das kollidiert die neu gespawnte Instanz beim schnellen
# Wechseln kurz mit der noch nicht ganz entfernten alten (beide exakt am
# selben Ort) und wird ueber move_and_slide() ein Stueck weggeschubst.
func _deactivate_old_player(old_player: CharacterBody3D) -> void:
	if old_player == null or not is_instance_valid(old_player):
		return

	old_player.set_physics_process(false)
	old_player.set_process(false)
	old_player.set_process_unhandled_input(false)
	old_player.collision_layer = 0
	old_player.collision_mask = 0
	old_player.velocity = Vector3.ZERO
	# BUGFIX: Auch aus der Player-Gruppe nehmen. Sonst zaehlt die noch
	# nicht freigegebene alte Instanz beim Raum-EntryTrigger als "Player"
	# und kann einen Raum ein zweites Mal triggern.
	old_player.remove_from_group(PLAYER_GROUP)

	for area: Node in old_player.find_children("*", "Area3D", true, false):
		area.monitoring = false
		area.monitorable = false
		area.collision_layer = 0
		area.collision_mask = 0

func switch_to(index: int) -> void:
	if index < 0 or index >= party.size():
		return
	if index == _active_index:
		return
	if not is_member_alive(index):
		return
	if index < _switch_cooldowns.size() and _switch_cooldowns[index] > 0.0:
		return

	if not has_player():
		# Noch keine (gueltige) Instanz vorhanden — einfach nur den Index umstellen,
		# der naechste register_spawn_point()/setup_party()-Aufruf spawnt
		# dann direkt den richtigen Charakter.
		_active_index = index
		active_character_changed.emit(index)
		return

	# Zustand der aktuellen Instanz sichern, bevor sie ersetzt wird.
	var carried_transform: Transform3D = _sanitize_spawn_transform(player.global_transform)
	var carried_camera_yaw: float = 0.0
	var carried_camera_pitch: float = 0.0
	var old_camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
	var old_spring_arm: SpringArm3D = player.get_node_or_null("CameraPivot/SpringArm3D")
	if old_camera_pivot:
		carried_camera_yaw = old_camera_pivot.rotation.y
	if old_spring_arm:
		carried_camera_pitch = old_spring_arm.rotation.x

	if _player_health != null and is_instance_valid(_player_health) \
			and _player_health.health_changed.is_connected(_on_player_health_changed):
		_player_health.health_changed.disconnect(_on_player_health_changed)

	# Der Charakter, den wir gerade VERLASSEN, kriegt den Cooldown — nicht
	# der neu ausgewaehlte.
	var leaving_index: int = _active_index
	if leaving_index >= 0 and leaving_index < _switch_cooldowns.size():
		_switch_cooldowns[leaving_index] = SWITCH_COOLDOWN_DURATION

	_deactivate_old_player(player)
	player.queue_free()
	player = null
	_player_health = null

	_active_index = index
	# switch_to() laeuft zur Laufzeit per Input-Event, nicht mitten in einer
	# Ready-Kaskade - hier bleibt der Aufruf bewusst SYNCHRON, weil direkt
	# danach mit dem neuen "player" weitergearbeitet wird (Kamera-Werte
	# uebertragen). Waere dieser Aufruf auch deferred, waere "player" an
	# der Stelle unten noch null.
	_spawn_active_character(carried_transform)

	if has_player():
		var new_camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
		var new_spring_arm: SpringArm3D = player.get_node_or_null("CameraPivot/SpringArm3D")
		if new_camera_pivot:
			new_camera_pivot.rotation.y = carried_camera_yaw
		if new_spring_arm:
			new_spring_arm.rotation.x = carried_camera_pitch

	active_character_changed.emit(index)

func get_active_index() -> int:
	return _active_index

func get_active_data() -> CharacterData:
	if _active_index >= 0 and _active_index < party.size():
		return party[_active_index]
	return null

func get_data(index: int) -> CharacterData:
	if index >= 0 and index < party.size():
		return party[index]
	return null

func get_party_size() -> int:
	return party.size()

func get_member_health(index: int) -> float:
	if index >= 0 and index < _current_health.size():
		return _current_health[index]
	return 0.0

func get_member_max_health(index: int) -> float:
	if index >= 0 and index < _max_health.size():
		return _max_health[index]
	return 1.0

func is_member_alive(index: int) -> bool:
	return get_member_health(index) > 0.0

# 1.0 = Cooldown gerade erst gestartet, 0.0 = bereit (fuers UI, gleiche
# Konvention wie Combat.get_cooldown_percent()).
func get_switch_cooldown_percent(index: int) -> float:
	if index < 0 or index >= _switch_cooldowns.size() or SWITCH_COOLDOWN_DURATION <= 0.0:
		return 0.0
	return _switch_cooldowns[index] / SWITCH_COOLDOWN_DURATION

func get_switch_cooldown_remaining(index: int) -> float:
	if index < 0 or index >= _switch_cooldowns.size():
		return 0.0
	return _switch_cooldowns[index]

func is_on_switch_cooldown(index: int) -> bool:
	return get_switch_cooldown_remaining(index) > 0.0

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	for i: int in range(MAX_PARTY_SIZE):
		var action: String = "switch_char_%d" % (i + 1)
		if InputMap.has_action(action) and event.is_action_pressed(action):
			switch_to(i)
			return


# ============================================================================
# Weisses Blinken waehrend der Last-Stand-Schonzeit
# ============================================================================
## Faerbt das Modell des Nachrueckers im selben psx.gdshader-Kanal wie die
## Item-Effekte (siehe item_behaviours.gd _flash_player) weiss ein und lässt
## flash_strength ueber die komplette Schonzeit zwischen 0 und
## SWITCH_BLINK_STRENGTH pulsieren, statt nur einmal aufzublitzen - das macht
## "ich bin gerade unverwundbar" sichtbar, nicht nur "ich wurde getroffen".
func _play_switch_invuln_blink(duration: float) -> void:
	if not has_player() or duration <= 0.0:
		return

	var materials: Array[ShaderMaterial] = []
	_collect_shader_materials(player, materials)
	if materials.is_empty():
		return

	for material: ShaderMaterial in materials:
		material.set_shader_parameter("flash_color", SWITCH_BLINK_COLOR)

	var half_cycle: float = SWITCH_BLINK_INTERVAL * 0.5
	var cycles: int = maxi(int(ceil(duration / SWITCH_BLINK_INTERVAL)), 1)

	# Auf PartyManager (Autoload) statt auf "player" erzeugt: player wird bei
	# einem weiteren schnellen Wechsel/Tod noch WAEHREND der Schonzeit
	# queue_free()'t, und ein an ihn gebundener Tween stuerbe mit ihm ab,
	# noch bevor flash_strength zurueckgesetzt ist.
	var tween: Tween = create_tween()
	tween.set_loops(cycles)
	tween.tween_method(
		func(value: float) -> void:
			for material: ShaderMaterial in materials:
				if is_instance_valid(material):
					material.set_shader_parameter("flash_strength", value),
		0.0, SWITCH_BLINK_STRENGTH, half_cycle
	)
	tween.tween_method(
		func(value: float) -> void:
			for material: ShaderMaterial in materials:
				if is_instance_valid(material):
					material.set_shader_parameter("flash_strength", value),
		SWITCH_BLINK_STRENGTH, 0.0, half_cycle
	)
	tween.finished.connect(
		func() -> void:
			for material: ShaderMaterial in materials:
				if is_instance_valid(material):
					material.set_shader_parameter("flash_strength", 0.0)
	)


## Gleiche Logik wie item_behaviours.gd _collect_shader_materials() - bewusst
## dupliziert statt geteilt, weil ItemBehaviours ein eigenstaendiges, an den
## jeweiligen Charakter gebundenes Node ist und PartyManager (Autoload) keine
## fixe Referenz darauf haelt.
func _collect_shader_materials(node: Node, out: Array[ShaderMaterial]) -> void:
	var mesh := node as MeshInstance3D
	if mesh != null:
		if mesh.material_override is ShaderMaterial:
			out.append(mesh.material_override as ShaderMaterial)
		else:
			for i: int in range(mesh.get_surface_override_material_count()):
				var surface: Material = mesh.get_surface_override_material(i)
				if surface is ShaderMaterial:
					out.append(surface as ShaderMaterial)
	for child: Node in node.get_children():
		_collect_shader_materials(child, out)
