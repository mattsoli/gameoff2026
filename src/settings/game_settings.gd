@tool
class_name GameSettings
extends Resource
## Punto d'ingresso di tutte le impostazioni di gioco. È assegnata all'autoload RunManager.

## Unico file di impostazioni del gioco (letto da RunManager e dal Level Editor).
const SETTINGS_PATH: String = "res://data/settings/game_settings.tres"

@export var game_title: String = "Shift Happens"
@export var player: PlayerDefinition
## Livelli in ordine di gioco.
@export var levels: Array[LevelDefinition] = []
@export var board: BoardVisualSettings
@export var combat: CombatSettings
## Cut scene di fine livello (pecora che scappa o viene presa).
@export var cutscene: CutsceneSettings
## Aspetto e animazioni dell'interfaccia (theme, sfondi, comparse, pulsanti).
@export var ui: UiSettings
## Colonna sonora ed effetti sonori.
@export var audio: AudioSettings

@export_group("Regole")
## Se true tenendo premuto un tasto direzione la pedina continua a muoversi.
@export var hold_to_move: bool = true
## Quanti livelli sono giocabili dalla schermata dei livelli (dal primo in poi).
## 0 = tutti sbloccati.
@export_range(0, 999) var unlocked_levels: int = 0

@export_group("Scene")
@export_file("*.tscn") var main_menu_scene: String = "res://scenes/main_menu/main_menu.tscn"
@export_file("*.tscn") var game_scene: String = "res://scenes/game/game.tscn"
@export_file("*.tscn") var level_select_scene: String = "res://scenes/level_select/level_select.tscn"

var _fallback_ui: UiSettings
var _fallback_audio: AudioSettings
var _fallback_cutscene: CutsceneSettings


## UiSettings sempre valide: se il campo `ui` è vuoto si usano i valori predefiniti.
func get_ui() -> UiSettings:
	if ui != null:
		return ui
	if _fallback_ui == null:
		_fallback_ui = UiSettings.new()
	return _fallback_ui


## AudioSettings sempre valide: se il campo `audio` è vuoto il gioco resta muto.
func get_audio() -> AudioSettings:
	if audio != null:
		return audio
	if _fallback_audio == null:
		_fallback_audio = AudioSettings.new()
	return _fallback_audio


## CutsceneSettings sempre valide: se il campo `cutscene` è vuoto si usano i valori predefiniti.
func get_cutscene() -> CutsceneSettings:
	if cutscene != null:
		return cutscene
	if _fallback_cutscene == null:
		_fallback_cutscene = CutsceneSettings.new()
	return _fallback_cutscene


## Numero di livelli giocabili nella schermata dei livelli.
func get_unlocked_level_count() -> int:
	if unlocked_levels <= 0:
		return levels.size()
	return mini(unlocked_levels, levels.size())
