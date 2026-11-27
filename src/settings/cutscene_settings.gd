@tool
class_name CutsceneSettings
extends Resource
## Cut scene di fine livello (pecora raggiunta).
## Sequenza: la pedina si ferma a metà del passo verso la pecora -> la board sparisce ->
## sullo sfondo compaiono giocatore e pecora ->
##   livelli intermedi: la pecora corre via dal lato opposto al giocatore;
##   ultimo livello: il giocatore raggiunge la pecora e la prende.
## Poi compare la finestra di fine livello.
## Posizione e dimensione dei due personaggi: trascinare PlayerActor e SheepActor
## in scenes/cutscene/goal_cutscene.tscn.

## Se false il livello si completa come prima, senza cut scene.
@export var enabled: bool = true

@export_group("Pedina")
## Quanta parte del passo verso la pecora fa la pedina prima di fermarsi (0.5 = metà).
@export_range(0.0, 1.0, 0.01) var pawn_stop_fraction: float = 0.5
## Movimento della pedina fino al punto in cui si ferma.
@export var pawn_stop: UiAnimation = UiAnimation.create(0.12)
## Attesa con la pedina ferma prima che la board sparisca.
@export_range(0.0, 5.0, 0.01, "suffix:s") var pause_after_stop: float = 0.15
## Scomparsa della board.
@export var board_hide: UiTransition = UiTransition.create_transition(0.3, Vector2.ZERO, Vector2(0.92, 0.92), Tween.TRANS_QUAD, Tween.EASE_IN)

@export_group("Personaggi")
## Lato del riquadro (in pixel) per cui sono disegnate le scene dei personaggi.
@export_range(16.0, 1024.0, 1.0) var scene_reference_size: float = 256.0
## Scena del giocatore. Vuoto = la combat_scene del giocatore (o la sua combat_texture).
@export var player_scene: PackedScene
## Le scene vanno disegnate con i piedi in (0, 0), come quelle del combattimento.
## Scena animata della pecora. Animazioni usate: "idle", "run" (mentre scappa), "caught" (presa).
@export var sheep_scene: PackedScene
## Immagine della pecora se non c'è una scena.
@export var sheep_texture: Texture2D
## Comparsa dei due personaggi sullo sfondo.
@export var player_appear: UiTransition = UiTransition.create_transition(0.35)
@export var sheep_appear: UiTransition = UiTransition.create_transition(0.35)
## Attesa con i due personaggi fermi prima della fuga o della cattura.
@export_range(0.0, 5.0, 0.01, "suffix:s") var pause_before_action: float = 0.5

@export_group("Fuga (livelli intermedi)")
## La pecora corre via: slide_offset = verso dove scappa (es. (1400, 0) = esce a destra).
@export var sheep_escape: UiTransition = _create_escape()
## Attesa dopo la fuga, prima della finestra di fine livello.
@export_range(0.0, 5.0, 0.01, "suffix:s") var pause_after_escape: float = 0.6

@export_group("Cattura (ultimo livello)")
## Il giocatore corre verso la pecora (in parallelo all'animazione "catch" della sua scena).
@export var player_catch: UiAnimation = UiAnimation.create(0.6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
## Quanta parte della distanza dalla pecora percorre il giocatore (1 = si sovrappone).
@export_range(0.0, 1.5, 0.01) var catch_distance: float = 0.75
## Attesa dopo la cattura, prima della finestra di vittoria.
@export_range(0.0, 5.0, 0.01, "suffix:s") var pause_after_catch: float = 0.8


static func _create_escape() -> UiTransition:
	var escape: UiTransition = UiTransition.create_transition(0.9, Vector2(1400.0, 0.0), Vector2.ONE, Tween.TRANS_QUAD, Tween.EASE_IN)
	escape.fade = false
	return escape
