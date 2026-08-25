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

	# TODO: Split into functions
	if event.is_action_pressed("card_select") \
		and GameManager.card_holder.can_place_card() \
		and Hex.currently_hovered \
		and Hex.currently_hovered.hex_data.type == HexData.Type.BLANK:

		Hex.currently_hovered.hex_data.type = HexData.Type.BLANK_UNPLACABLE

		var card := GameManager.card_holder.take_currently_dragged(self)
		var grid_pos = Hex.currently_hovered.hex_position

		var screen_pos = GameManager.card_holder.cards_container.to_global(card.position)
		card.position = get_viewport().get_canvas_transform().affine_inverse() * screen_pos
		card.scale = Vector2.ONE

		# Infinite cards for fun
		GameManager.card_holder.add_card(load("res://const_data/cards/test_card.tres"))

		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_method(func(vec: Vector2): card.position = vec,
			card.position,
			grid_pos.to_pixel() + Vector2.UP*40,
			0.3
		)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_method(func(vec: Vector2): card.position = vec,
			grid_pos.to_pixel() + Vector2.UP*40,
			grid_pos.to_pixel(),
			0.2
		)

		tween.finished.connect(func():
			GameManager.hex_grid.clear_hex_at(grid_pos)
			GameManager.hex_grid.spawn_hex_at(grid_pos, card.card_data.hex_data)
			card.queue_free()
		)
