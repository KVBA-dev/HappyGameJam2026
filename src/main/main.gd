## This node always stays as a root of the scene tree
class_name Main extends Node

@onready var tooltip_canvas: TooltipCanvas = %TooltipCanvas
@onready var cursor: Cursor = %Cursor

var cursor_normal: Texture2D = preload("res://assets/images/cursors/resized/happy_cursor_base.png")
var cursor_pointer: Texture2D = preload("res://assets/images/cursors/resized/happy_pointer_base.png")

var paused: bool = true
var paths_visible: bool = true
# NOTE: treat it as a set
var items_produced: Dictionary[ItemData, bool]
var factories: Array[FactoryHex]
var stats: Stats = Stats.new()

static func new_instance() -> Main:
	var main: Main = GameManager.scenes.MAIN_SCENE.instantiate()
	return main

func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_normal, Input.CursorShape.CURSOR_ARROW, Vector2(16, 0))
	Input.set_custom_mouse_cursor(cursor_pointer, Input.CursorShape.CURSOR_POINTING_HAND, Vector2(11, 0))
	
	SignalBus.main_loaded.emit()
	SignalBus.item_produced.connect(_on_item_produced)
	SignalBus.game_reset.connect(on_game_reset)
	GameManager.main = self
	GameManager.hex_grid.surround_with_hexes(3)

	SignalBus.factory_connected.connect(_on_factory_connected)
	SignalBus.card_used.connect(_on_card_used)
	GameManager.hex_grid.deleted_hex.connect(_on_hex_grid_deleted_hex)
	GameManager.hex_grid.spawned_hex.connect(_on_hex_grid_spawned_hex)

	spawn_available_factory_hexes(false)
	
	paused = true
	SignalBus.pause_toggled.emit(paused)

func _on_factory_connected(_factory: FactoryHex):
	for factory: FactoryHex in factories:
		if not factory.connected.value:
			return
	spawn_available_factory_hexes(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = not paused
		SignalBus.pause_toggled.emit(paused)

func _on_item_produced(item: ItemData) -> void:
	if item not in items_produced:
		SignalBus.item_achieved.emit(item)
	items_produced[item] = true

func on_game_reset() -> void:
	stats = Stats.new()
	factories = []
	items_produced = {}
	GameManager.paths.clear_all_paths()
	GameManager.progress_tree.rebuild()
	GameManager.hex_grid.reset_grid()
	GameManager.hex_grid.surround_with_hexes(3)
	spawn_available_factory_hexes(false)

func spawn_available_factory_hexes(emit_signals: bool = true) -> void:
	var batches: Array[ProgressBatch] = GameManager.progress_tree.get_batch()
	if len(batches) > 0 and emit_signals:
		SignalBus.factory_unlocked.emit()
	for batch: ProgressBatch in batches:
		for hex_data: HexData in batch.buildings:
			var blank_hex: Hex = GameManager.hex_grid.get_random_blank_hex_in_spawn_range()
			if blank_hex == null:
				push_error("No blank hex is within spawn range")
				return

			var hex_position := blank_hex.hex_position
			GameManager.hex_grid.clear_hex_at(hex_position)
			GameManager.hex_grid.spawn_hex_at(hex_position, hex_data, Hex.AppearStyle.Below)

	GameManager.progress_tree.confirm_batches_spawned(batches)


func _on_card_used(card: CardHudBase, pos: HexVector):
	print(stats.cards_used)
	stats.add_card(card.card_data, pos)

func _on_hex_grid_deleted_hex(position: HexVector):
	pass
func _on_hex_grid_spawned_hex(hex: Hex):
	pass
