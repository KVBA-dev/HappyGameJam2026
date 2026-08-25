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
	GameManager.hex_grid.surround_with_hexes(5)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = not paused
		SignalBus.pause_toggled.emit(paused)
