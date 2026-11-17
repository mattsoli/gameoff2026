@tool
class_name EditorTestLevel
extends RefCounted
## Passa dall'editor al gioco il livello da provare (pulsante "Test level" del Level Editor).
## L'editor scrive il percorso del livello in un file in user://; il gioco lo legge
## una sola volta all'avvio e lo cancella. Funziona solo avviando il gioco dall'editor.

const REQUEST_FILE: String = "user://editor_test_level.txt"


## Chiamato dall'editor prima di avviare la scena di gioco.
static func request(level: LevelDefinition) -> Error:
	var file: FileAccess = FileAccess.open(REQUEST_FILE, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(level.resource_path)
	return OK


## Chiamato dal gioco: restituisce il livello richiesto (o null) e cancella la richiesta.
static func consume() -> LevelDefinition:
	if not OS.has_feature("editor") or not FileAccess.file_exists(REQUEST_FILE):
		return null
	var path: String = FileAccess.get_file_as_string(REQUEST_FILE).strip_edges()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(REQUEST_FILE))
	if not ResourceLoader.exists(path):
		return null
	return load(path) as LevelDefinition
