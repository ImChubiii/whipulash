extends "res://test/base/party_manager_test_base.gd"

# ============================================================================
# Regressionstest: Charakterwechsel waehrend ein Winter-Plasma-Bolt fliegt
# ============================================================================
# BUG (Rueckmeldung 2026-08-12): Haelt man als Winter den Primärangriff
# (LMB / Input-Action "attack_primary") gedrueckt und wechselt WAEHREND ein
# Plasma-Bolt noch unterwegs ist zu Karina, stuerzte das Spiel ab.
#
# URSACHE: HomingBolt._strike() (scripts/vfx/homing_bolt.gd) rief seinen
# on_strike-Callback bis dahin UNBEDINGT auf. Dieser Callback ist eine
# Closure, die an den feuernden CombatWinter-Node gebunden ist (siehe
# combat_winter.gd::_perform_primary(), Callable "on_strike" -> ruft
# _on_plasma_strike() auf "self" auf). party_manager.gd::switch_to() gibt
# den alten Spieler samt seinem Combat-Kind-Node aber SOFORT frei
# (queue_free()), sobald man den Charakter wechselt. Der Bolt selbst haengt
# unabhaengig davon unter current_scene und fliegt weiter - trifft er sein
# Ziel NACH dem Wechsel, ruft er den Callback auf einer bereits
# freigegebenen Instanz auf. Das crashte das Spiel.
#
# FIX: homing_bolt.gd::_strike() prueft jetzt "_on_strike.is_valid()",
# bevor es den Callback aufruft, und ueberspringt ihn sonst einfach.
#
# Dieser Test bildet das Szenario 1:1 nach UND beweist zusaetzlich, dass er
# wirklich den gefaehrlichen Pfad trifft (der alte Combat-Node ist nach dem
# Wechsel tatsaechlich freigegeben, und der In-Flight-Bolt versucht
# tatsaechlich noch zuzuschlagen) - er soll nicht zufaellig gruen sein, nur
# weil der Bolt z.B. nie abgefeuert oder nie faellig wurde.

const TARGET_INDEX_KARINA: int = 1

## Muss deutlich groesser sein als HomingBolt.HIT_RANGE (1.3) UND als die
## Strecke, die ein Bolt in den ein/zwei Frames bis zum Charakterwechsel
## zuruecklegt (plasma_bolt_speed=24.0 in combat_winter.gd) - sonst koennte
## der Bolt sein Ziel schon VOR dem Wechsel treffen und der Test wuerde den
## kritischen Zeitraum verfehlen.
const BOLT_TRAVEL_DISTANCE: float = 6.0

## Frames, die dem Bolt NACH dem Wechsel gegeben werden, um seine Restdistanz
## zu fliegen und _strike() auszuloesen. 6.0 / 24.0 = 0.25s Flugzeit; 30
## Frames (~0.5s bei 60 FPS) lassen reichlich Puffer, ohne den Test spuerbar
## zu verlangsamen.
const FRAMES_TO_LET_BOLT_ARRIVE: int = 30


func test_switch_to_karina_while_winter_bolt_in_flight_does_not_crash() -> void:
	var winter_data: CharacterData = load(WINTER_DATA)
	var karina_data: CharacterData = load(KARINA_DATA)
	var party_members: Array[CharacterData] = [winter_data, karina_data]
	await spawn_party(party_members)

	assert_true(PartyManager.has_player(), "Winter sollte gespawnt sein")
	assert_eq(
		PartyManager.get_active_data().character_id, &"winter",
		"Winter sollte der aktive Charakter sein (party_members[0])"
	)

	var winter_player: PlayerBase = PartyManager.player as PlayerBase
	var winter_combat: CombatBase = winter_player.combat
	assert_true(winter_combat is CombatWinter, "Der Combat-Node der aktiven Instanz sollte CombatWinter sein")

	# Ziel fuer Winters Plasma-Bolt: weit genug entfernt, dass er beim
	# Charakterwechsel garantiert noch unterwegs ist.
	var dummy_enemy: Node3D = spawn_dummy_enemy(
		winter_player.global_position + Vector3.FORWARD * BOLT_TRAVEL_DISTANCE
	)
	var dummy_health: Health = dummy_enemy.get_node("Health") as Health

	# --- Primärangriff "gedrückt halten" -----------------------------------
	# combat_base.gd::_poll_primary_input() pollt Input.is_action_pressed()
	# direkt jeden Frame - echtes Halten der Taste wird dadurch exakt so
	# simuliert, wie es die Rueckmeldung beschreibt ("LMB gedrückt gehalten").
	# Ein einzelner Frame reicht: primary_cooldown startet bei 0.0, der
	# allererste _process()-Tick mit gedrueckter Taste feuert also sofort
	# und spawnt den HomingBolt (siehe combat_winter.gd::_perform_primary()).
	Input.action_press(&"attack_primary")
	await wait_frames(1)
	Input.action_release(&"attack_primary")

	# --- Charakterwechsel MITTEN im Flug -------------------------------------
	# switch_to() laeuft synchron (siehe party_manager.gd-Kommentar dort) -
	# direkt danach steht entweder schon die neue Instanz, oder der Test ist
	# an genau der Stelle abgestuerzt, die vorher den Bug reproduziert hat.
	PartyManager.switch_to(TARGET_INDEX_KARINA)

	# --- Der Wechsel selbst war erfolgreich ----------------------------------
	assert_eq(
		PartyManager.get_active_index(), TARGET_INDEX_KARINA,
		"Aktiver Party-Index sollte nach dem Wechsel auf Karina stehen"
	)
	assert_true(PartyManager.has_player(), "Nach dem Wechsel sollte wieder ein lebender Spieler existieren")
	assert_eq(
		PartyManager.get_active_data().character_id, &"karina",
		"Aktive Charakter-Daten sollten Karina sein"
	)
	assert_true(PartyManager.player is CharKarina, "Die neue Spieler-Instanz sollte CharKarina sein")

	# --- Beweis, dass wirklich der kritische Pfad getroffen wurde ------------
	# Ohne diese Pruefung koennte der Test auch gruen sein, weil der Bolt aus
	# irgendeinem Grund nie feuerte - dann waere er wertlos als Regressions-
	# schutz. is_instance_valid() muss hier false sein: switch_to() hat den
	# alten Spieler samt Combat-Kind bereits per queue_free() entsorgt.
	await wait_frames(1)
	assert_false(
		is_instance_valid(winter_combat),
		"Der alte Winter-Combat-Node sollte nach dem Wechsel freigegeben sein - sonst testet dieser Test nicht den kritischen Pfad"
	)
	assert_false(
		is_instance_valid(winter_player),
		"Die alte Winter-Spieler-Instanz sollte nach dem Wechsel freigegeben sein"
	)

	# --- Den Bolt seine Flugzeit fertig fliegen lassen ------------------------
	# Das ist der eigentliche Regressionstest: VOR dem Fix in homing_bolt.gd
	# haette dieser Frame-Vorlauf zu einem Aufruf auf einer freigegebenen
	# Instanz gefuehrt (Absturz). Kommt der Test hier ueberhaupt an und
	# schlaegt die folgende Assertion nicht fehl, ist der Callback sicher
	# uebersprungen worden.
	await wait_frames(FRAMES_TO_LET_BOLT_ARRIVE)
	assert_eq(
		dummy_health.current_health, dummy_health.max_health,
		"Der In-Flight-Bolt darf nach dem Wechsel keinen Schaden mehr anwenden - der Callback haengt am freigegebenen Winter-Combat-Node und muss von HomingBolt._strike() sicher uebersprungen werden"
	)

	# --- Input-State sauber zurueckgesetzt ------------------------------------
	assert_false(
		Input.is_action_pressed(&"attack_primary"),
		"attack_primary sollte nach dem Loslassen nicht mehr als gedrueckt gelten"
	)

	# --- Karina ist nach dem Wechsel tatsaechlich benutzbar -------------------
	var karina_combat: CombatBase = (PartyManager.player as PlayerBase).combat
	assert_true(is_instance_valid(karina_combat), "Karinas Combat-Node sollte gueltig sein")
	assert_false(
		is_nan(karina_combat.get_primary_cooldown_percent()),
		"Karinas Primary-Cooldown sollte ein normaler Wert sein, kein NaN aus haengendem Zustand"
	)

	assert_no_new_orphans("Der Charakterwechsel waehrend eines fliegenden Bolts sollte keine Nodes verwaisen lassen")
