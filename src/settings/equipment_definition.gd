@tool
class_name EquipmentDefinition
extends Resource
## Oggetto equipaggiabile dal giocatore in uno dei due slot.

enum Slot { WEAPON, ARMOR }

@export var id: StringName
@export var display_name: String = ""
@export var slot: Slot = Slot.WEAPON
## Monete di combattimento aggiunte finché l'oggetto è equipaggiato.
@export_range(0, 99) var bonus_coins: int = 0
## Effetti aggiuntivi applicati in combattimento.
@export var effects: Array[CombatEffect] = []
@export var icon: Texture2D
