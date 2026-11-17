class_name ArrivalResult
extends RefCounted
## Cosa è successo quando la pedina è entrata in una casella.

var cell: Vector2i
var picked_key: bool = false
var opened_chest: ChestEntity
var reached_goal: bool = false
## Valorizzato se nella casella c'era una freccia (lo shift è già applicato al modello).
var shift: ShiftResult
