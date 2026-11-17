class_name ResultOverlay
extends CanvasLayer
## Finestra modale generica con titolo, messaggio e fino a due scelte
## (livello completato, sconfitta, errori nel livello...).

signal choice_made

@onready var _title_label: Label = %TitleLabel
@onready var _message_label: Label = %MessageLabel
@onready var _primary_button: Button = %PrimaryButton
@onready var _secondary_button: Button = %SecondaryButton

var _is_primary_chosen: bool = false


func _ready() -> void:
	visible = false
	_primary_button.pressed.connect(_choose.bind(true))
	_secondary_button.pressed.connect(_choose.bind(false))


## Mostra la finestra e attende la scelta. Restituisce true se è stato premuto il pulsante principale.
## Se secondary_text è vuoto il secondo pulsante viene nascosto.
func ask(title: String, message: String, primary_text: String, secondary_text: String = "") -> bool:
	_title_label.text = title
	_message_label.text = message
	_message_label.visible = not message.is_empty()
	_primary_button.text = primary_text
	_secondary_button.text = secondary_text
	_secondary_button.visible = not secondary_text.is_empty()
	visible = true
	_primary_button.grab_focus()
	await choice_made
	visible = false
	return _is_primary_chosen


func _choose(is_primary: bool) -> void:
	_is_primary_chosen = is_primary
	choice_made.emit()
