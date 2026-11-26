@tool
class_name CombatSettings
extends Resource
## Regole, tempi e animazioni della schermata di combattimento.
## Lo sfondo della schermata è in UiSettings; testi e font nel Theme.

@export_group("Regole")
## Cosa succede se giocatore e nemico hanno lo stesso valore di attacco.
## true = vince il giocatore, false = vince il nemico (game over).
@export var player_wins_ties: bool = true

@export_group("Tempi")
## Tempo in cui i valori di attacco restano in evidenza prima della risoluzione automatica.
@export_range(0.0, 5.0, 0.01, "suffix:s") var pause_before_resolution: float = 1.0
## Tempo in cui l'esito resta a schermo prima di chiudere la schermata.
@export_range(0.0, 5.0, 0.01, "suffix:s") var result_pause: float = 0.8

@export_group("Animazioni")
## Lato del riquadro (in pixel) per cui sono disegnate le scene di combattimento (combat_scene).
@export_range(16.0, 1024.0, 1.0) var scene_reference_size: float = 256.0
## Apertura della schermata di combattimento.
@export var intro: UiTransition = UiTransition.create_transition(0.4)
## Chiusura della schermata di combattimento.
@export var outro: UiTransition = UiTransition.create_transition(0.3, Vector2.ZERO, Vector2.ONE, Tween.TRANS_QUAD, Tween.EASE_IN)
## Scatto del vincitore verso l'avversario...
@export var attack: UiAnimation = UiAnimation.create(0.14)
## ...e ritorno al suo posto.
@export var attack_return: UiAnimation = UiAnimation.create(0.21, Tween.TRANS_QUAD, Tween.EASE_IN)
## Lunghezza dello scatto, in frazione della larghezza dello sprite.
@export_range(0.0, 2.0, 0.01) var attack_distance: float = 0.4
## Lo sconfitto subisce il colpo: lampeggia, cambia scala e sbiadisce.
@export var defeat: UiAnimation = UiAnimation.create(0.4)
@export var defeat_flash_color: Color = Color(1.0, 0.35, 0.35)
@export var defeat_scale: Vector2 = Vector2(0.7, 0.7)
@export_range(0.0, 1.0, 0.01) var defeat_final_alpha: float = 0.2
## Comparsa della scritta con l'esito.
@export var result_appear: UiTransition = UiTransition.create_transition(0.3, Vector2(0.0, 20.0))
