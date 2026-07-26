extends RefCounted
class_name DetRng

## Deterministische Zufalls-Helfer fuer verifizierbare Speedruns.
##
## WARUM DAS NOETIG IST:
## Godots globale Funktionen randf(), randi(), Array.shuffle() und
## Array.pick_random() greifen ALLE auf denselben globalen RNG zu. In
## Lemonade zieht daran aber nicht nur die Levelgenerierung, sondern auch:
##   - player_base.gd  -> randf_range() pro Frame fuer den Screen-Shake
##   - damage_number.gd -> randf_range() bei JEDER Schadenszahl
##   - enemy_ai.gd     -> randf_range() fuer Tempo-Varianz und Ausweichen
##
## Folge: RoomInstance._spawn_prepared_enemies() wird erst ausgefuehrt,
## wenn der Spieler den Raum betritt - der globale RNG ist zu dem
## Zeitpunkt schon zigtausend Aufrufe weit gelaufen, und WIE weit haengt
## davon ab, wie oft der Spieler getroffen wurde und wie lange die Kamera
## gewackelt hat. Zwei Laeufe mit identischem Seed erzeugen dadurch
## garantiert unterschiedliche Gegner-Zusammensetzungen.
##
## Ein Seed auf dem Leaderboard waere damit reine Dekoration: niemand
## koennte den Run nachspielen. Deshalb bekommen Layout, Raumauswahl und
## Gegner-Rolls jeweils EIGENE RandomNumberGenerator-Instanzen, die aus
## dem Run-Seed abgeleitet werden. Der globale RNG bleibt fuer Optik
## (Shake, Partikel, Schadenszahlen) zustaendig und darf dort ruhig
## weiterlaufen - er beeinflusst dann nichts Spielrelevantes mehr.

## Zeichen fuer den teilbaren Seed-Code. I und O fehlen bewusst: die
## verwechselt jeder mit 1 und 0, sobald der Code aus einem Stream
## abgetippt wird.
const ALPHABET: String = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ"

## Obergrenze fuer Run-Seeds. Muss in einen int32 passen, weil Steam die
## Leaderboard-Details als PackedInt32Array uebertraegt.
const MAX_SEED: int = 2147483646


## Fertig geseedete RNG-Instanz.
static func make(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


## Leitet aus einem Basis-Seed und einem Text-Salt einen neuen Seed ab.
##
## Benutzt eine SplitMix64-artige Durchmischung statt einer simplen
## Addition: benachbarte Salts ("spawn:(0,0)" und "spawn:(0,1)") sollen
## weit auseinander liegende Seeds liefern, sonst haetten benachbarte
## Raeume sichtbar aehnliche Gegner-Rolls.
static func derive(base_seed: int, salt: String) -> int:
	var x: int = base_seed ^ (hash(salt) * 0x9E3779B97F4A7C15)
	x = (x ^ (x >> 30)) * 0xBF58476D1CE4E5B9
	x = (x ^ (x >> 27)) * 0x94D049BB133111EB
	x = x ^ (x >> 31)
	return x


## Fisher-Yates ueber einen ANGEGEBENEN RNG. Array.shuffle() waere hier
## unbrauchbar, weil es zwingend den globalen RNG benutzt.
static func shuffle(array: Array, rng: RandomNumberGenerator) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Variant = array[i]
		array[i] = array[j]
		array[j] = tmp


## Ersatz fuer Array.pick_random() mit eigenem RNG.
static func pick(array: Array, rng: RandomNumberGenerator) -> Variant:
	if array.is_empty():
		return null
	return array[rng.randi_range(0, array.size() - 1)]


## Frischer, zufaelliger Run-Seed im gueltigen int32-Bereich.
static func random_seed_value() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(1, MAX_SEED)


## Seed -> teilbarer Code ("4F2K9"). Kuerzer und vorlesbarer als die
## Dezimalzahl, was fuer Daily-Seeds und Stream-Overlays der Punkt ist.
static func seed_to_code(seed_value: int) -> String:
	var value: int = clampi(absi(seed_value), 0, MAX_SEED)
	if value == 0:
		return "0"

	var base: int = ALPHABET.length()
	var out: String = ""
	while value > 0:
		out = ALPHABET[value % base] + out
		value /= base
	return out


## Code -> Seed. Liefert 0, wenn der Code ungueltige Zeichen enthaelt -
## der Aufrufer behandelt 0 dann als "kein Seed angegeben".
static func code_to_seed(code: String) -> int:
	var cleaned: String = code.strip_edges().to_upper().replace("-", "")
	if cleaned.is_empty():
		return 0

	var base: int = ALPHABET.length()
	var value: int = 0
	for i in range(cleaned.length()):
		var index: int = ALPHABET.find(cleaned[i])
		if index < 0:
			return 0
		value = value * base + index
		if value > MAX_SEED:
			return 0
	return value
