class_name GoalCutscene
extends CanvasLayer
## Cut scene di fine livello, sullo sfondo del gioco (la board l'ha già nascosta GameController).
## Livelli intermedi: la pecora corre via; ultimo livello: il giocatore la raggiunge e la prende.
## Posizione e dimensione dei personaggi: trascinare PlayerActor e SheepActor in questa scena.
## Tempi e transizioni: CutsceneSettings. Resta a schermo sotto la finestra di fine livello.

@onready var _player_actor: StageActor = %PlayerActor
@onready var _sheep_actor: StageActor = %SheepActor


func _ready() -> void:
	visible = false


## Esegue la cut scene. `sheep_escapes` = true nei livelli intermedi, false nell'ultimo.
func play(player: PlayerDefinition, sheep_escapes: bool, settings: CutsceneSettings) -> void:
	var player_scene: PackedScene = settings.player_scene if settings.player_scene != null else player.combat_scene
	_player_actor.setup_actor(player_scene, player.combat_texture, player.color, settings.scene_reference_size)
	_sheep_actor.setup_actor(settings.sheep_scene, settings.sheep_texture, Color.WHITE, settings.scene_reference_size)

	# --- Comparsa ---
	UiAnimator.reset(_player_actor)
	UiAnimator.reset(_sheep_actor)
	UiAnimator.prepare_in(_player_actor, settings.player_appear)
	UiAnimator.prepare_in(_sheep_actor, settings.sheep_appear)
	visible = true
	UiAnimator.play_in(_player_actor, settings.player_appear)
	await UiAnimator.play_in(_sheep_actor, settings.sheep_appear)
	await _wait(settings.pause_before_action)

	if sheep_escapes:
		await _play_escape(settings)
	else:
		await _play_catch(settings)


## La pecora corre via (animazione "run" mentre scorre fuori dallo schermo).
func _play_escape(settings: CutsceneSettings) -> void:
	AudioManager.play_sfx(AudioManager.get_settings().sheep_escape)
	_sheep_actor.play_animation(SceneVisual.RUN)
	await UiAnimator.play_out(_sheep_actor, settings.sheep_escape)
	await _wait(settings.pause_after_escape)


## Il giocatore raggiunge la pecora ("catch"), che viene presa ("caught").
func _play_catch(settings: CutsceneSettings) -> void:
	var started: int = Time.get_ticks_msec()
	var scene_length: float = _player_actor.play_one_shot(SceneVisual.CATCH)
	var target: Vector2 = _player_actor.position.lerp(_sheep_actor.position, settings.catch_distance)
	var tween: Tween = create_tween()
	UiAnimation.tween_property(tween, _player_actor, "position", target, settings.player_catch)
	await tween.finished
	await SceneVisual.wait_remaining(get_tree(), started, scene_length)
	AudioManager.play_sfx(AudioManager.get_settings().sheep_caught)
	var caught_length: float = _sheep_actor.play_one_shot(SceneVisual.CAUGHT)
	await _wait(maxf(caught_length, settings.pause_after_catch))


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
