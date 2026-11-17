class_name GameHud
extends MarginContainer
## Barra superiore: informazioni sul livello e sul giocatore, pulsanti Riprova e Menu.

signal restart_requested
signal menu_requested

@export var level_format: String = "Level %d - %s"
@export var hp_format: String = "HP %d / %d"
@export var coins_format: String = "Coins: %d"
@export var key_missing_text: String = "Key: no"
@export var key_found_text: String = "Key: yes"
@export var weapon_format: String = "Weapon: %s"
@export var armor_format: String = "Armor: %s"
@export var empty_slot_text: String = "-"

@onready var _level_label: Label = %LevelLabel
@onready var _hp_label: Label = %HpLabel
@onready var _coins_label: Label = %CoinsLabel
@onready var _key_label: Label = %KeyLabel
@onready var _weapon_label: Label = %WeaponLabel
@onready var _armor_label: Label = %ArmorLabel
@onready var _restart_button: Button = %RestartButton
@onready var _menu_button: Button = %MenuButton


func _ready() -> void:
	_restart_button.pressed.connect(restart_requested.emit)
	_menu_button.pressed.connect(menu_requested.emit)


func refresh(level_number: int, level_name: String, player: PlayerState, has_key: bool) -> void:
	_level_label.text = level_format % [level_number, level_name]
	_hp_label.text = hp_format % [player.hp, player.max_hp]
	_coins_label.text = coins_format % player.get_total_coin_count()
	_key_label.text = key_found_text if has_key else key_missing_text
	_weapon_label.text = weapon_format % _get_item_name(player.weapon)
	_armor_label.text = armor_format % _get_item_name(player.armor)


func _get_item_name(item: EquipmentDefinition) -> String:
	return empty_slot_text if item == null else item.display_name
