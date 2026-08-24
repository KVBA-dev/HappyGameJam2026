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

	if event.is_action_pressed("card_select") \
		and GameManager.card_holder.can_place_card() \
		and Hex.currently_hovered \
		and Hex.currently_hovered.hex_data.type == HexData.Type.BLANK:

		var card: CardData = GameManager.card_holder.take_currently_dragged()
		var pos = Hex.currently_hovered.hex_position

		GameManager.hex_grid.clear_hex_at(pos)
		GameManager.hex_grid.spawn_hex_at(pos, card.hex_data)
