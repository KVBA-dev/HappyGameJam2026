## This node always stays as a root of the scene tree
class_name Main extends Node

@onready var tooltip_canvas: TooltipCanvas = %TooltipCanvas
@onready var cursor: Cursor = %Cursor

var paused: bool = false
var paths_visible: bool = true
# NOTE: treat it as a set
var items_produced: Dictionary[ItemData, bool]
var factories: Array[FactoryHex]

static func new_instance() -> Main:
	var main: Main = GameManager.scenes.MAIN_SCENE.instantiate()
	return main

func _ready() -> void:
	SignalBus.main_loaded.emit()
	SignalBus.item_produced.connect(_on_item_produced)
	SignalBus.game_reset.connect(on_game_reset)
	GameManager.main = self
	GameManager.hex_grid.surround_with_hexes(3)

	# Infinite cards for fun
	SignalBus.card_used.connect(func(_a, _b):
		GameManager.card_holder.add_card(GameManager.cards.pick_random())
	)
	SignalBus.factory_connected.connect(_on_factory_connected)
	spawn_available_factory_hexes()

func _on_factory_connected(_factory: FactoryHex):
	for factory: FactoryHex in factories:
		if not factory.connected.value:
			return
	spawn_available_factory_hexes()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = not paused
		SignalBus.pause_toggled.emit(paused)

func _on_item_produced(item: ItemData) -> void:
	if item not in items_produced:
		# TODO: advance with factory hexes
		print("Made for first time: %s" % item)
	items_produced[item] = true

func on_game_reset() -> void:
	GameManager.hex_grid.reset_grid()
	GameManager.hex_grid.surround_with_hexes(3)
	spawn_available_factory_hexes()

func spawn_available_factory_hexes() -> void:
	var batches: Array[ProgressBatch] = GameManager.progress_tree.get_batch()

	for batch: ProgressBatch in batches:
		for hex_data: HexData in batch.buildings:
			var blank_hex: Hex = GameManager.hex_grid.get_random_blank_hex_in_spawn_range()
			if blank_hex == null:
				push_error("No blank hex is within spawn range")
				return

			var hex_position := blank_hex.hex_position
			GameManager.hex_grid.clear_hex_at(hex_position)
			GameManager.hex_grid.spawn_hex_at(hex_position, hex_data)
