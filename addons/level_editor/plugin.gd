@tool
extends EditorPlugin
## Registra il Level Editor nell'Inspector: si attiva selezionando una LevelDefinition (.tres).

var _inspector_plugin: LevelInspectorPlugin


func _enter_tree() -> void:
	_inspector_plugin = LevelInspectorPlugin.new()
	_inspector_plugin.undo_redo = get_undo_redo()
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)
	_inspector_plugin = null
