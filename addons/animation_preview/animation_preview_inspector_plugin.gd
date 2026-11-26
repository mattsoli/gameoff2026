@tool
class_name AnimationPreviewInspectorPlugin
extends EditorInspectorPlugin
## Mostra un'anteprima animata in cima all'Inspector di:
## - UiAnimation / UiTransition -> curva + quadrato di esempio (AnimationPreview);
## - ButtonFeedback             -> pulsante di esempio che reagisce in loop (ButtonFeedbackPreview).
## Funziona anche quando la risorsa è aperta dentro un'altra (es. ui_settings.tres).


func _can_handle(object: Object) -> bool:
	return object is UiAnimation or object is ButtonFeedback


func _parse_begin(object: Object) -> void:
	if object is ButtonFeedback:
		var button_preview: ButtonFeedbackPreview = ButtonFeedbackPreview.new()
		button_preview.feedback = object as ButtonFeedback
		add_custom_control(button_preview)
		return
	var preview: AnimationPreview = AnimationPreview.new()
	preview.animation = object as UiAnimation
	add_custom_control(preview)
