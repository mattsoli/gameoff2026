@tool
class_name CombatSettings
extends Resource
## Regole, tempi e animazioni del combattimento.
## Sequenza: la board sparisce -> giocatore e nemico entrano in scena sullo sfondo ->
## il vincitore attacca -> lo sconfitto lampeggia e fa la sua animazione di sconfitta ->
## i combattenti escono -> la board ricompare.
## Lo sfondo opzionale del combattimento è in UiSettings; testi e font nel Theme;
## posizione e dimensione dei combattenti nella scena scenes/combat/combat_screen.tscn.

@export_group("Regole")
## Cosa succede se giocatore e nemico hanno lo stesso valore di attacco.
## true = vince il giocatore, false = vince il nemico (game over).
@export var player_wins_ties: bool = true

@export_group("Tempi")
## Tempo in cui i combattenti restano fermi in scena prima dell'attacco.
@export_range(0.0, 5.0, 0.01, "suffix:s") var pause_before_resolution: float = 1.0
## Tempo in cui l'esito resta a schermo prima che i combattenti escano.
@export_range(0.0, 5.0, 0.01, "suffix:s") var result_pause: float = 0.8

@export_group("Board")
## Scomparsa della board all'inizio del combattimento.
@export var board_hide: UiTransition = UiTransition.create_transition(0.25, Vector2.ZERO, Vector2(0.92, 0.92), Tween.TRANS_QUAD, Tween.EASE_IN)
## Ricomparsa della board dopo un combattimento vinto (se perso, il livello ricomincia).
@export var board_show: UiTransition = UiTransition.create_transition(0.3, Vector2.ZERO, Vector2(0.92, 0.92))

@export_group("Entrata e uscita")
## Comparsa e scomparsa di titolo e sfondo del combattimento (se assegnato in UiSettings).
@export var intro: UiTransition = UiTransition.create_transition(0.3)
@export var outro: UiTransition = UiTransition.create_transition(0.3, Vector2.ZERO, Vector2.ONE, Tween.TRANS_QUAD, Tween.EASE_IN)
## Entrata in scena del giocatore (slide_offset = da dove arriva, es. (-600, 0) = da sinistra).
@export var player_enter: UiTransition = UiTransition.create_transition(0.45, Vector2(-600.0, 0.0))
## Entrata in scena del nemico (es. (600, 0) = da destra).
@export var enemy_enter: UiTransition = UiTransition.create_transition(0.45, Vector2(600.0, 0.0))
## Uscita di scena del giocatore a fine combattimento.
@export var player_exit: UiTransition = UiTransition.create_transition(0.3, Vector2(-600.0, 0.0), Vector2.ONE, Tween.TRANS_QUAD, Tween.EASE_IN)
## Uscita di scena del nemico a fine combattimento.
@export var enemy_exit: UiTransition = UiTransition.create_transition(0.3, Vector2(0.0, 40.0), Vector2(0.8, 0.8), Tween.TRANS_QUAD, Tween.EASE_IN)

@export_group("Attacco")
## Lato del riquadro (in pixel) per cui sono disegnate le scene di combattimento (combat_scene):
## la scena viene scalata alla dimensione del riquadro del combattente in combat_screen.tscn.
@export_range(16.0, 1024.0, 1.0) var scene_reference_size: float = 256.0
## Scatto del vincitore verso l'avversario (in parallelo all'animazione "attack" della scena)...
@export var attack: UiAnimation = UiAnimation.create(0.14)
## ...e ritorno al suo posto.
@export var attack_return: UiAnimation = UiAnimation.create(0.21, Tween.TRANS_QUAD, Tween.EASE_IN)
## Lunghezza dello scatto, in frazione della larghezza del riquadro. 0 = nessuno scatto
## (utile se il movimento è già nell'animazione "attack" della scena).
@export_range(0.0, 2.0, 0.01) var attack_distance: float = 0.4

@export_group("Sconfitta")
## Quante volte lampeggia lo sconfitto (in parallelo all'animazione "defeat" della scena). 0 = mai.
@export_range(0, 20) var defeat_blink_count: int = 4
## Durata di ogni lampeggio (andata verso il colore e ritorno contano come due).
@export var defeat_blink: UiAnimation = UiAnimation.create(0.07, Tween.TRANS_LINEAR)
## Colore del lampeggio: trasparenza 0 = sparisce e ricompare, un colore = flash colorato.
@export var defeat_blink_color: Color = Color(1.0, 0.35, 0.35, 0.25)
## Comparsa della scritta con l'esito.
@export var result_appear: UiTransition = UiTransition.create_transition(0.3, Vector2(0.0, 20.0))
