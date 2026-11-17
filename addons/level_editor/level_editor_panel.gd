@tool
class_name LevelEditorPanel
extends VBoxContainer
## Pannello del Level Editor mostrato nell'Inspector di una LevelDefinition.
## Flusso: scegli un "pennello" dalla palette (casella, elemento o freccia) e dipingi sulla griglia.
## Ogni pennellata riscrive i layout del livello, ricontrolla il livello con LevelParser
## ed è annullabile con Ctrl+Z (EditorUndoRedoManager).

signal test_requested(level: LevelDefinition)

const DEFAULT_LEGEND_PATH: String = "res://data/levels/default_legend.tres"
const DEFAULT_GRID_SIZE: Vector2i = Vector2i(6, 6)
const MAX_GRID_SIZE: int = 20
const ICON_SIZE: int = 18
const VALID_COLOR: Color = Color(0.45, 0.85, 0.5)
const ERROR_COLOR: Color = Color(1.0, 0.5, 0.45)
const HINT_COLOR: Color = Color(0.7, 0.7, 0.75)
const ARROW_BUTTONS: Array[Dictionary] = [
	{ "text": "↑ Up", "direction": Direction.Type.UP },
	{ "text": "→ Right", "direction": Direction.Type.RIGHT },
	{ "text": "↓ Down", "direction": Direction.Type.DOWN },
	{ "text": "← Left", "direction": Direction.Type.LEFT },
]

var _level: LevelDefinition
var _undo_redo: EditorUndoRedoManager
var _grid: LevelLayoutGrid
var _brush_layer: LevelLayoutGrid.Layer = LevelLayoutGrid.Layer.TILES
var _brush_symbol: String = ""
## True mentre il pannello stesso scrive nel livello (evita di ricaricarsi da solo).
var _is_writing: bool = false
var _stroke_before: PackedStringArray = PackedStringArray()
var _palette_legend: LevelLegend
var _brush_group: ButtonGroup

var _legend_box: VBoxContainer
var _editor_box: VBoxContainer
var _width_spin: SpinBox
var _height_spin: SpinBox
var _tiles_flow: HFlowContainer
var _entities_flow: HFlowContainer
var _arrows_flow: HFlowContainer
var _grid_view: LevelGridView
var _empty_label: Label
var _hover_label: Label
var _validation_label: Label
var _test_button: Button
var _add_to_game_button: Button


func setup(level: LevelDefinition, undo_redo: EditorUndoRedoManager) -> void:
	_level = level
	_undo_redo = undo_redo
	_build_ui()
	_level.changed.connect(_on_level_changed)
	_reload()


func _exit_tree() -> void:
	if _level != null and _level.changed.is_connected(_on_level_changed):
		_level.changed.disconnect(_on_level_changed)


# --- Costruzione interfaccia ------------------------------------------------

func _build_ui() -> void:
	add_theme_constant_override("separation", 8)
	var title: Label = Label.new()
	title.text = "Level Editor"
	title.add_theme_font_size_override("font_size", 18)
	add_child(title)

	_legend_box = VBoxContainer.new()
	add_child(_legend_box)
	_legend_box.add_child(_make_hint("This level has no legend: it is needed to know which tiles and elements exist."))
	var legend_button: Button = Button.new()
	legend_button.text = "Use default legend"
	legend_button.pressed.connect(_on_use_default_legend_pressed)
	_legend_box.add_child(legend_button)

	_editor_box = VBoxContainer.new()
	_editor_box.add_theme_constant_override("separation", 8)
	add_child(_editor_box)
	_build_size_row()
	_tiles_flow = _add_palette_section("Tiles")
	_entities_flow = _add_palette_section("Elements")
	_arrows_flow = _add_palette_section("Shift arrows")

	_empty_label = _make_hint("Empty level: choose a size and press \"Apply size\".")
	_editor_box.add_child(_empty_label)
	_grid_view = LevelGridView.new()
	_grid_view.stroke_started.connect(_on_stroke_started)
	_grid_view.cell_painted.connect(_on_cell_painted)
	_grid_view.stroke_finished.connect(_on_stroke_finished)
	_grid_view.cell_hovered.connect(_on_cell_hovered)
	_editor_box.add_child(_grid_view)

	_hover_label = _make_hint(" ")
	_editor_box.add_child(_hover_label)
	_editor_box.add_child(_make_hint("Left click: paint · Right click: erase · Drag to paint more cells · Ctrl+Z: undo"))
	_validation_label = Label.new()
	_validation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_editor_box.add_child(_validation_label)
	_build_action_row()
	add_child(HSeparator.new())


func _build_size_row() -> void:
	# HFlowContainer: va a capo se l'Inspector è stretto invece di allargare il pannello.
	var row: HFlowContainer = HFlowContainer.new()
	_editor_box.add_child(row)
	_width_spin = _add_size_spin(row, "Width")
	_height_spin = _add_size_spin(row, "Height")
	var apply_button: Button = Button.new()
	apply_button.text = "Apply size"
	apply_button.pressed.connect(_on_apply_size_pressed)
	row.add_child(apply_button)


func _add_size_spin(row: HFlowContainer, text: String) -> SpinBox:
	var label: Label = Label.new()
	label.text = text
	row.add_child(label)
	var spin: SpinBox = SpinBox.new()
	spin.min_value = 1
	spin.max_value = MAX_GRID_SIZE
	row.add_child(spin)
	return spin


func _add_palette_section(text: String) -> HFlowContainer:
	var label: Label = Label.new()
	label.text = text
	_editor_box.add_child(label)
	var flow: HFlowContainer = HFlowContainer.new()
	_editor_box.add_child(flow)
	return flow


func _build_action_row() -> void:
	var row: HFlowContainer = HFlowContainer.new()
	_editor_box.add_child(row)
	_test_button = Button.new()
	_test_button.text = "▶ Test level"
	_test_button.tooltip_text = "Save the level and run the game scene on it."
	_test_button.pressed.connect(func() -> void: test_requested.emit(_level))
	row.add_child(_test_button)
	_add_to_game_button = Button.new()
	_add_to_game_button.pressed.connect(_on_add_to_game_pressed)
	row.add_child(_add_to_game_button)


func _make_hint(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", HINT_COLOR)
	return label


# --- Palette ------------------------------------------------------------------

## Ricostruisce i pulsanti solo se è cambiata la legenda (non a ogni pennellata).
func _rebuild_palette() -> void:
	var legend: LevelLegend = _level.legend
	if legend == _palette_legend:
		return
	_palette_legend = legend
	_brush_group = ButtonGroup.new()
	for flow: HFlowContainer in [_tiles_flow, _entities_flow, _arrows_flow]:
		for child: Node in flow.get_children():
			child.queue_free()

	for symbol: String in legend.tiles:
		var tile: TileDefinition = legend.tiles[symbol]
		_add_brush_button(_tiles_flow, _get_name(tile.display_name, symbol), _make_icon(tile.color, tile.texture), LevelLayoutGrid.Layer.TILES, symbol)
	_add_brush_button(_entities_flow, "Player start", _make_icon(LevelGridView.PLAYER_COLOR, null), LevelLayoutGrid.Layer.ENTITIES, legend.player_start_symbol)
	for symbol: String in legend.entities:
		var entity: EntityDefinition = legend.entities[symbol]
		_add_brush_button(_entities_flow, _get_name(entity.display_name, symbol), _make_icon(entity.color, entity.texture), LevelLayoutGrid.Layer.ENTITIES, symbol)
	_add_brush_button(_entities_flow, "✕ Remove", null, LevelLayoutGrid.Layer.ENTITIES, legend.empty_symbol)
	for arrow: Dictionary in ARROW_BUTTONS:
		var direction: Direction.Type = arrow["direction"]
		var text: String = arrow["text"]
		_add_brush_button(_arrows_flow, text, null, LevelLayoutGrid.Layer.ARROWS, _get_arrow_symbol(direction))
	_add_brush_button(_arrows_flow, "✕ Remove", null, LevelLayoutGrid.Layer.ARROWS, legend.empty_symbol)

	_select_first_brush()


func _add_brush_button(flow: HFlowContainer, text: String, icon: Texture2D, layer: LevelLayoutGrid.Layer, symbol: String) -> void:
	var button: Button = Button.new()
	button.text = text
	button.icon = icon
	button.toggle_mode = true
	button.button_group = _brush_group
	button.tooltip_text = "Symbol in the .tres file: '%s'" % symbol
	button.add_theme_constant_override("icon_max_width", ICON_SIZE)
	button.pressed.connect(_set_brush.bind(layer, symbol))
	flow.add_child(button)


func _select_first_brush() -> void:
	var buttons: Array[BaseButton] = _brush_group.get_buttons()
	if buttons.is_empty():
		return
	buttons[0].button_pressed = true
	buttons[0].pressed.emit() # imposta il pennello come un click


func _set_brush(layer: LevelLayoutGrid.Layer, symbol: String) -> void:
	_brush_layer = layer
	_brush_symbol = symbol


# --- Sincronizzazione con il livello -------------------------------------------

func _on_level_changed() -> void:
	if not _is_writing:
		_reload()


## Rilegge il livello (all'apertura, dopo un Undo/Redo o un cambio di legenda).
func _reload() -> void:
	var has_legend: bool = _level.legend != null
	_legend_box.visible = not has_legend
	_editor_box.visible = has_legend
	if not has_legend:
		return

	_rebuild_palette()
	_grid = LevelLayoutGrid.from_level(_level, _get_default_tile(), _level.legend.empty_symbol)
	var shown_size: Vector2i = DEFAULT_GRID_SIZE if _grid.is_empty() else _grid.size
	_width_spin.value = shown_size.x
	_height_spin.value = shown_size.y
	_grid_view.setup(_grid, _level.legend)
	_refresh_status()


func _write_level() -> void:
	_is_writing = true
	_grid.write_to(_level)
	_is_writing = false
	_grid_view.queue_redraw()
	_refresh_status()


func _refresh_status() -> void:
	_empty_label.visible = _grid.is_empty()
	_refresh_validation()
	_refresh_action_buttons()


## Usa lo stesso LevelParser del gioco: se qui è verde, il livello si carica.
func _refresh_validation() -> void:
	if _grid.is_empty():
		_validation_label.text = ""
		return
	var parsed: ParsedLevel = LevelParser.parse(_level)
	if parsed.is_valid():
		_validation_label.text = "✔ Level is valid (%d × %d)" % [_grid.size.x, _grid.size.y]
		_validation_label.add_theme_color_override("font_color", VALID_COLOR)
	else:
		_validation_label.text = "✖ Fix these problems:\n• " + "\n• ".join(parsed.errors)
		_validation_label.add_theme_color_override("font_color", ERROR_COLOR)


func _refresh_action_buttons() -> void:
	var is_saved_file: bool = _level.resource_path.begins_with("res://") and not _level.resource_path.contains("::")
	_test_button.disabled = not is_saved_file or _grid.is_empty()
	var settings: GameSettings = load(GameSettings.SETTINGS_PATH)
	var index: int = settings.levels.find(_level)
	_add_to_game_button.disabled = index != -1 or not is_saved_file
	_add_to_game_button.text = "In game as level %d" % (index + 1) if index != -1 else "Add to game levels"


# --- Pittura ----------------------------------------------------------------

func _on_stroke_started() -> void:
	_stroke_before = LevelLayoutGrid.read_layouts(_level)


func _on_cell_painted(cell: Vector2i, is_erase: bool) -> void:
	var symbol: String = _brush_symbol
	if is_erase:
		symbol = _get_default_tile() if _brush_layer == LevelLayoutGrid.Layer.TILES else _level.legend.empty_symbol

	var changed: bool = false
	# La partenza del giocatore è unica: dipingerla altrove sposta quella esistente.
	if _brush_layer == LevelLayoutGrid.Layer.ENTITIES and symbol == _level.legend.player_start_symbol:
		for other: Vector2i in _grid.find_cells(LevelLayoutGrid.Layer.ENTITIES, symbol):
			changed = _grid.set_symbol(LevelLayoutGrid.Layer.ENTITIES, other, _level.legend.empty_symbol) or changed
	changed = _grid.set_symbol(_brush_layer, cell, symbol) or changed
	if changed:
		_write_level()


func _on_stroke_finished() -> void:
	_register_undo("Paint level", _stroke_before)


func _on_cell_hovered(cell: Vector2i) -> void:
	if cell == LevelGridView.INVALID_CELL:
		_hover_label.text = " "
		return
	var legend: LevelLegend = _level.legend
	var parts: PackedStringArray = ["(%d, %d)" % [cell.x, cell.y]]
	var tile_symbol: String = _grid.get_symbol(LevelLayoutGrid.Layer.TILES, cell)
	if legend.tiles.has(tile_symbol):
		parts.append(_get_name(legend.tiles[tile_symbol].display_name, tile_symbol))
	var entity_symbol: String = _grid.get_symbol(LevelLayoutGrid.Layer.ENTITIES, cell)
	if entity_symbol == legend.player_start_symbol:
		parts.append("Player start")
	elif legend.entities.has(entity_symbol):
		parts.append(_get_name(legend.entities[entity_symbol].display_name, entity_symbol))
	var direction: Direction.Type = legend.get_arrow_direction(_grid.get_symbol(LevelLayoutGrid.Layer.ARROWS, cell))
	if direction != Direction.Type.NONE:
		var direction_name: String = Direction.Type.keys()[direction]
		parts.append("arrow " + direction_name.to_lower())
	_hover_label.text = " · ".join(parts)


# --- Pulsanti -----------------------------------------------------------------

func _on_apply_size_pressed() -> void:
	var new_size: Vector2i = Vector2i(int(_width_spin.value), int(_height_spin.value))
	if new_size == _grid.size:
		return
	var before: PackedStringArray = LevelLayoutGrid.read_layouts(_level)
	_grid.resize(new_size, _get_default_tile(), _level.legend.empty_symbol)
	_write_level()
	_grid_view.setup(_grid, _level.legend)
	_register_undo("Resize level", before)


func _on_use_default_legend_pressed() -> void:
	var legend: LevelLegend = load(DEFAULT_LEGEND_PATH)
	if _undo_redo == null:
		_level.legend = legend
		return
	_undo_redo.create_action("Assign default legend")
	_undo_redo.add_do_property(_level, "legend", legend)
	_undo_redo.add_undo_property(_level, "legend", _level.legend)
	_undo_redo.commit_action()


## Aggiunge il livello in fondo alla lista delle GameSettings e salva il file.
func _on_add_to_game_pressed() -> void:
	var settings: GameSettings = load(GameSettings.SETTINGS_PATH)
	if settings.levels.has(_level):
		return
	var levels: Array[LevelDefinition] = settings.levels.duplicate()
	levels.append(_level)
	settings.levels = levels
	var error: Error = ResourceSaver.save(settings)
	if error != OK:
		push_error("Level Editor: impossibile salvare le GameSettings (errore %d)" % error)
	_refresh_action_buttons()


# --- Utility ------------------------------------------------------------------

## Le modifiche sono già applicate: l'azione registra solo come annullarle/ripeterle.
func _register_undo(action_name: String, before: PackedStringArray) -> void:
	var after: PackedStringArray = LevelLayoutGrid.read_layouts(_level)
	if _undo_redo == null or after == before:
		return
	_undo_redo.create_action(action_name)
	for layer: int in LevelLayoutGrid.LAYER_PROPERTIES.size():
		var property: String = LevelLayoutGrid.LAYER_PROPERTIES[layer]
		_undo_redo.add_do_property(_level, property, after[layer])
		_undo_redo.add_undo_property(_level, property, before[layer])
	_undo_redo.commit_action(false)


## Casella usata per riempire celle nuove o cancellate: la prima calpestabile e non obiettivo.
func _get_default_tile() -> String:
	var legend: LevelLegend = _level.legend
	for symbol: String in legend.tiles:
		var tile: TileDefinition = legend.tiles[symbol]
		if tile.is_walkable and not tile.is_goal:
			return symbol
	for symbol: String in legend.tiles:
		return symbol # nessuna casella calpestabile: usa la prima disponibile
	return legend.empty_symbol


func _get_arrow_symbol(direction: Direction.Type) -> String:
	var legend: LevelLegend = _level.legend
	match direction:
		Direction.Type.UP:
			return legend.arrow_up_symbol
		Direction.Type.RIGHT:
			return legend.arrow_right_symbol
		Direction.Type.DOWN:
			return legend.arrow_down_symbol
		_:
			return legend.arrow_left_symbol


static func _get_name(display_name: String, symbol: String) -> String:
	return symbol if display_name.is_empty() else display_name


static func _make_icon(color: Color, texture: Texture2D) -> Texture2D:
	if texture != null:
		return texture
	var image: Image = Image.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)
