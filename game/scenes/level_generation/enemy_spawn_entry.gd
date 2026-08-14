extends Resource
class_name EnemySpawnEntry

## Ein Eintrag in der Gegner-Tabelle des LevelGenerators.
##
## Statt "spawne 3-5 zufaellige Gegner aus einem Array" laeuft das Spawnen
## jetzt ueber ein THREAT-BUDGET: jeder Raum bekommt ein Punktebudget,
## jeder Gegnertyp kostet Punkte. Dadurch kann ein Raum entweder viele
## billige Stinger ODER wenige teure Fighter enthalten - die Schwierigkeit
## bleibt vergleichbar, die Zusammensetzung wird trotzdem abwechslungsreich.

## Die zu spawnende Gegner-Szene.
@export var scene: PackedScene

## Nur fuer Logs/Debug - der echte Anzeigename kommt aus enemy_ai.display_name.
@export var display_name: String = ""

## Relative Ziehwahrscheinlichkeit innerhalb aller aktuell gueltigen
## Eintraege (hoeher = haeufiger).
@export var weight: float = 1.0

## Wie viele Budgetpunkte dieser Gegner kostet. Faustregel:
##   Stinger  = 1  (schnell, 25 HP)
##   Fighter  = 3  (traege, 100 HP, 30 Schaden)
##   Colossus = 10 (Boss, 400 HP)
@export var threat_cost: int = 1

## Ab welcher Stage dieser Gegnertyp ueberhaupt auftauchen darf.
## Stage 1 = erste Etage. Fighter erst ab Stage 1, damit die erste Etage
## nicht sofort ueberfordert - hochsetzen, wenn es zu schnell zu hart wird.
@export var min_stage: int = 1

## Obergrenze pro Raum, unabhaengig vom Budget. Verhindert z.B. 4 Fighter
## in einem Raum, auch wenn das Budget das theoretisch hergeben wuerde.
@export var max_per_room: int = 99

## Mindest-Raumhoehe, die dieser Gegner braucht. Der Colossus ist ~12
## Units hoch und passt nur in die 24 Units hohe Boss-Arena.
@export var min_room_height: float = 0.0

## Wie viele Exemplare IMMER gesetzt werden, bevor das restliche Budget
## zufaellig verwuerfelt wird. Fuer den Colossus auf 1 stellen - sonst
## koennte die Gewichtung im Bossraum theoretisch nur Stinger ziehen und
## der Boss fehlt komplett. Die Kosten werden vom Budget abgezogen.
@export var guaranteed_count: int = 0

## Mindest-Abstand zu anderen Gegnern beim Verteilen auf die Spawn-Marker.
## Grosse Gegner brauchen mehr Platz, damit sie sich nicht ineinander
## schieben und sofort auseinanderdriften.
@export var min_spawn_spacing: float = 0.0

## Teurer/gefaehrlicher Gegnertyp (Colossus, Schild-Drohne, ...). Ab Stage 4
## kauft RoomInstance._roll_enemy_mix() Elite-Eintraege zuerst, bevor der
## Rest des Budgets mit billigen Gegnern aufgefuellt wird - sonst ertrinkt
## das steigende Budget im Lategame nur in immer mehr Stingern/Fightern statt
## in mehr Bedrohung.
@export var is_elite: bool = false

func is_allowed(stage: int, room_height: float) -> bool:
	if scene == null:
		return false
	if stage < min_stage:
		return false
	if room_height < min_room_height:
		return false
	return true
