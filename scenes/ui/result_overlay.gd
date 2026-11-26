class_name ResultOverlay
extends CanvasLayer
## Finestra modale generica con titolo, messaggio e fino a due scelte
## (livello completato, vittoria, errori nel livello...).
## Colore di oscuramento e animazioni di comparsa/scomparsa vengono da UiSettings.

signal choice_made

@onready var _dim: ColorRect = %Dim
@onready var _panel: Control = %Panel
@onready var _title_label: Label = %TitleLabel
@onready var _message_label: Label = %MessageLabel
@onready var _primary_button: Button = %PrimaryButton
@onready var _secondary_button: Button = %SecondaryButton

var _ui: UiSettings
var _is_primary_chosen: bool = false
var _has_chosen: bool = false


func _ready() -> void:
	visible = false
	_primary_button.pressed.connect(_choose.bind(true))
	_secondary_button.pressed.connect(_choose.bind(false))


func apply_ui(ui: UiSettings) -> void:
	_ui = ui
	_dim.color = ui.overlay_dim_color
	UiAnimator.attach_button_feedback(_primary_button, ui)
	UiAnimator.attach_button_feedback(_secondary_button, ui)


## Mostra la finestra e attende la scelta. Restituisce true se è stato premuto il pulsante principale.
## Se secondary_text è vuoto il secondo pulsante viene nascosto.
func ask(title: String, message: String, primary_text: String, secondary_text: String = "") -> bool:
	_title_label.text = title
	_message_label.text = message
	_message_label.visible = not message.is_empty()
	_primary_button.text = primary_text
	_secondary_button.text = secondary_text
	_secondary_button.visible = not secondary_text.is_empty()
	_has_chosen = false
	await _open()
	_primary_button.grab_focus()
	# Un clic durante l'animazione di apertura è già stato registrato: non va atteso di nuovo.
	if not _has_chosen:
		await choice_made
	await _close()
	return _is_primary_chosen


func _open() -> void:
	var appear: UiTransition = _ui.overlay_appear if _ui != null else null
	UiAnimator.prepare_in(_panel, appear)
	_dim.modulate.a = 0.0
	visible = true
	# Il pannello è centrato da un CenterContainer: si anima dopo che ha preso posto e misura.
	await get_tree().process_frame
	UiAnimator.fade_to(_dim, 1.0, appear)
	await UiAnimator.play_in(_panel, appear)


func _close() -> void:
	var disappear: UiTransition = _ui.overlay_disappear if _ui != null else null
	UiAnimator.fade_to(_dim, 0.0, disappear)
	await UiAnimator.play_out(_panel, disappear)
	visible = false
	UiAnimator.reset(_panel)
	_dim.modulate.a = 1.0


func _choose(is_primary: bool) -> void:
	_is_primary_chosen = is_primary
	_has_chosen = true
	choice_made.emit()
