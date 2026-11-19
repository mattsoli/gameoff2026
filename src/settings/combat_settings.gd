@tool
class_name CombatSettings
extends Resource
## Regole e tempi della schermata di combattimento.

@export_group("Regole")
## Cosa succede se giocatore e nemico hanno lo stesso valore di attacco.
## true = vince il giocatore, false = vince il nemico (game over).
@export var player_wins_ties: bool = true

@export_group("Animazioni")
@export_range(0.0, 3.0, 0.01) var intro_duration: float = 0.4
## Tempo in cui i valori di attacco restano in evidenza prima della risoluzione automatica.
@export_range(0.0, 5.0, 0.01) var pause_before_resolution: float = 1.0
@export_range(0.0, 3.0, 0.01) var attack_duration: float = 0.35
@export_range(0.0, 3.0, 0.01) var defeat_duration: float = 0.4
## Tempo in cui l'esito resta a schermo prima di chiudere la schermata.
@export_range(0.0, 5.0, 0.01) var result_pause: float = 0.8
@export_range(0.0, 3.0, 0.01) var outro_duration: float = 0.3
