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

@export_group("Regole")
## Se true gli HP del giocatore tornano al massimo a ogni nuovo livello.
@export var heal_between_levels: bool = false
## Se true tenendo premuto un tasto direzione la pedina continua a muoversi.
@export var hold_to_move: bool = true
## 0 = seed casuale a ogni partita. Un valore fisso rende i lanci riproducibili (debug).
@export var rng_seed: int = 0

@export_group("Scene")
@export_file("*.tscn") var main_menu_scene: String = "res://scenes/main_menu/main_menu.tscn"
@export_file("*.tscn") var game_scene: String = "res://scenes/game/game.tscn"
