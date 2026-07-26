extends Node

# ============================================================================
# Juice — Autoload fuer Hit-Stop, Freeze-Frames und Shake-Weiterleitung.
# Muss unter Project Settings -> Autoload als "Juice" eingetragen sein.
# ============================================================================
#
# HIT-STOP: Bei schweren Treffern wird Engine.time_scale fuer 0.05-0.08 s
# fast auf 0 gezogen. Das ist der billigste und wirksamste Wucht-Verstaerker,
# den es gibt — es kostet keine Animation, kein VFX, kein Sound.
#
# ZWEI FALLSTRICKE, die hier bewusst geloest sind:
#
# 1. Der Timer, der time_scale wieder hochsetzt, darf NICHT selbst
#    zeitskaliert sein. get_tree().create_timer() laeuft standardmaessig in
#    skalierter Zeit — bei time_scale = 0.0 wuerde er nie ablaufen und das
#    Spiel bliebe fuer immer eingefroren. Deshalb das vierte Argument
#    (ignore_time_scale = true).
#
# 2. Ueberlappende Hit-Stops. Trifft waehrend eines laufenden Stops ein
#    zweiter Treffer, wird NICHT gestapelt (sonst friert eine Combo das Spiel
#    sekundenlang ein), sondern nur die Restdauer verlaengert, gedeckelt bei
#    max_hit_stop_duration.
#
# Ein pausiertes Spiel wird nie angefasst: process_mode ALWAYS sorgt zwar
# dafuer, dass dieses Autoload weiterlaeuft, aber ein Hit-Stop waehrend
# get_tree().paused wuerde beim Entpausieren einen falschen time_scale
# hinterlassen.

signal hit_stop_started(duration: float)
signal hit_stop_ended

## Global abschaltbar (z.B. fuer Barrierefreiheit oder Speedrun-Puristen).
var hit_stop_enabled: bool = true

## Obergrenze, damit sich Treffer in einer langen Combo nicht aufsummieren.
var max_hit_stop_duration: float = 0.12

## Voreinstellungen fuer die drei Wuchtklassen.
const DURATION_LIGHT: float = 0.03
const DURATION_HEAVY: float = 0.06
const DURATION_EXPLOSION: float = 0.08

## Nicht exakt 0.0: bei time_scale = 0.0 stehen auch alle Partikel und
## Tweens komplett still, was den Frame "tot" wirken laesst. 0.02 haelt
## minimale Restbewegung drin und liest sich als bewusster Effekt.
const FROZEN_TIME_SCALE: float = 0.02

var _remaining: float = 0.0
var _is_active: bool = false
var _scale_before: float = 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Kurzer Freeze-Frame. duration in ECHTEN Sekunden.
func hit_stop(duration: float = DURATION_HEAVY) -> void:
	if not hit_stop_enabled or duration <= 0.0:
		return
	if get_tree().paused:
		return

	if _is_active:
		# Nicht stapeln, nur verlaengern — und hart deckeln.
		_remaining = minf(_remaining + duration * 0.5, max_hit_stop_duration)
		return

	_scale_before = Engine.time_scale
	_remaining = minf(duration, max_hit_stop_duration)
	_is_active = true
	Engine.time_scale = FROZEN_TIME_SCALE
	hit_stop_started.emit(_remaining)


func hit_stop_light() -> void:
	hit_stop(DURATION_LIGHT)


func hit_stop_heavy() -> void:
	hit_stop(DURATION_HEAVY)


func hit_stop_explosion() -> void:
	hit_stop(DURATION_EXPLOSION)


## Sofort aufraeumen — wird beim Szenenwechsel und beim Pausieren gebraucht,
## sonst startet das naechste Level mit eingefrorener Zeit.
func cancel() -> void:
	if not _is_active:
		return
	_is_active = false
	_remaining = 0.0
	Engine.time_scale = _scale_before
	hit_stop_ended.emit()


func is_active() -> bool:
	return _is_active


# Der Countdown laeuft ueber _process mit delta aus der ECHTEN Zeit: bei
# process_mode ALWAYS liefert Godot hier weiterhin unskaliertes delta ueber
# get_process_delta_time() NICHT — deshalb wird bewusst die Systemzeit
# genutzt statt delta, das mit time_scale schrumpft.
var _last_ticks: int = 0


func _process(_delta: float) -> void:
	if not _is_active:
		_last_ticks = Time.get_ticks_usec()
		return

	var now: int = Time.get_ticks_usec()
	var real_delta: float = float(now - _last_ticks) / 1_000_000.0
	_last_ticks = now

	# Erster Frame nach dem Start kann durch einen Ladehaenger riesig sein.
	real_delta = minf(real_delta, 0.1)

	_remaining -= real_delta
	if _remaining <= 0.0:
		_is_active = false
		Engine.time_scale = _scale_before
		hit_stop_ended.emit()


# ============================================================================
# Shake-Weiterleitung
# ============================================================================
# Bomben, Explosionen und Umgebungsereignisse kennen den Spieler nicht und
# sollen ihn auch nicht suchen muessen. shake() findet ihn ueber die Gruppe
# "player" — dieselbe Gruppe, die auch SettingsManager benutzt.
func shake(amount: float) -> void:
	for player: Node in get_tree().get_nodes_in_group("player"):
		if player.has_method("shake_camera"):
			player.shake_camera(amount)


## Kombi fuer schwere Treffer: erst einfrieren, dann wackeln.
func impact(shake_amount: float = 0.5, stop_duration: float = DURATION_HEAVY) -> void:
	hit_stop(stop_duration)
	shake(shake_amount)
