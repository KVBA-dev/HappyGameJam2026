## This node always stays as a root of the scene tree
class_name Main extends Node

@onready var tooltip_canvas: TooltipCanvas = %TooltipCanvas

var paused: bool = false

static func new_instance() -> Main:
	var main: Main = GameManager.scenes.MAIN_SCENE.instantiate()
	return main

func _ready() -> void:
	SignalBus.main_loaded.emit()
	GameManager.main = self
	GameManager.hex_grid.surround_with_hexes(3)

#	var batches: Array[ProgressBatch] = GameManager.progress_tree.get_batch()
#
#	for batch: ProgressBatch in batches:
#		for hex_data: HexData in batch.buildings:
#			var blank_hex := GameManager.hex_grid.get_random_blank_hex_in_spawn_range()
#			if blank_hex == null:
#				push_error("No blank hex is within spawn range")
#				return
#
#			var hex_position := blank_hex.hex_position
#			GameManager.hex_grid.clear_hex_at(hex_position)
#			GameManager.hex_grid.spawn_hex_at(hex_position, hex_data)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = not paused
		SignalBus.pause_toggled.emit(paused)
