@tool
class_name LevelInspectorPlugin
extends EditorInspectorPlugin
## Inserisce il LevelEditorPanel in cima all'Inspector delle LevelDefinition
## e nasconde i layout testuali (li scrive il pannello).
## Qui sta tutto ciò che usa le API dell'editor; il pannello resta solo interfaccia.

const HIDDEN_PROPERTIES: PackedStringArray = ["tiles_layout", "entities_layout", "arrows_layout"]

var undo_redo: EditorUndoRedoManager


func _can_handle(object: Object) -> bool:
	return object is LevelDefinition


func _parse_begin(object: Object) -> void:
	var panel: LevelEditorPanel = LevelEditorPanel.new()
	panel.setup(object as LevelDefinition, undo_redo)
	panel.test_requested.connect(_on_test_requested)
	add_custom_control(panel)


func _parse_property(_object: Object, _type: Variant.Type, name: String, _hint_type: PropertyHint, _hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	return HIDDEN_PROPERTIES.has(name)


## Salva il livello e avvia la scena di gioco direttamente su di esso.
func _on_test_requested(level: LevelDefinition) -> void:
	var error: Error = ResourceSaver.save(level)
	if error != OK:
		push_error("Level Editor: impossibile salvare '%s' (errore %d)" % [level.resource_path, error])
		return
	error = EditorTestLevel.request(level)
	if error != OK:
		push_error("Level Editor: impossibile preparare il test (errore %d)" % error)
		return
	var settings: GameSettings = load(GameSettings.SETTINGS_PATH)
	EditorInterface.play_custom_scene(settings.game_scene)
