@tool
extends EditorPlugin
## Registra l'anteprima delle animazioni nell'Inspector.

var _inspector_plugin: AnimationPreviewInspectorPlugin


func _enter_tree() -> void:
	_inspector_plugin = AnimationPreviewInspectorPlugin.new()
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)
	_inspector_plugin = null
