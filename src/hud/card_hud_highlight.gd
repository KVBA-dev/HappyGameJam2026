class_name CardHudHighlight extends Sprite2D

@onready var shadow_sprite: Sprite2D = %ShadowSprite

const MIN_Z_INDEX = 0

enum State {
	IN_HAND,
	PREVIEWED,
	DRAGGED,
	PLACED
}

var target_pos: Vector2 = self.position
var target_scale: Vector2 = Vector2.ONE
var card_data: CardData

var _scale_to_camera: bool = false
var _insta_scale: bool = false

@onready var card_holder: CardHolder = get_tree().get_first_node_in_group("card_holder")
var _state: State = State.IN_HAND
var state: State:
	get:
		return _state
	set(value):
		var previous = _state
		_state = value
		_on_state_change(previous)

var _hover: bool = false
var hover: bool:
	get:
		return _hover

func _process(delta: float) -> void:
	match _state:
		State.IN_HAND: _in_hand_processed(delta)
		State.PREVIEWED: _previewed_process(delta)
		State.DRAGGED: _dragged_process(delta)

func _in_hand_processed(delta: float):
	const MOVE_SPEED = 5.0
	position = Vector2(
		Utils.smooth_exp(position.x, target_pos.x, MOVE_SPEED, delta),
		Utils.smooth_exp(position.y, target_pos.y, MOVE_SPEED, delta)
	)

func _previewed_process(delta: float):
	const MOVE_SPEED = 5.0
	position = Vector2(
		Utils.smooth_exp(position.x, target_pos.x, MOVE_SPEED, delta),
		Utils.smooth_exp(position.y, target_pos.y, MOVE_SPEED, delta)
	)

func _dragged_process(delta: float):
	const FOLLOW_SPEED = 12.0
	global_position = Vector2(
		Utils.smooth_exp(global_position.x, get_global_mouse_position().x, FOLLOW_SPEED, delta),
		Utils.smooth_exp(global_position.y, get_global_mouse_position().y, FOLLOW_SPEED, delta)
	)

	if _scale_to_camera:
		target_scale = get_viewport().get_camera_2d().zoom

		if (target_scale - scale).length() <= 0.01:
			_insta_scale = true

		if _insta_scale:
			scale = target_scale

	const SCALE_SPEED = 10.0
	scale = Vector2(
		Utils.smooth_exp(scale.x, target_scale.x, SCALE_SPEED, delta),
		Utils.smooth_exp(scale.y, target_scale.y, SCALE_SPEED, delta)
	)

func _on_area_2d_mouse_entered() -> void:
	_hover = true

func _on_area_2d_mouse_exited() -> void:
	_hover = false

func _on_state_change(_previous: State):
	match _state:
		State.IN_HAND: 
			scale = Vector2.ONE 
			shadow_sprite.z_index = -10
		State.PREVIEWED:
			scale = Vector2.ONE * 1.2
			rotation = 0
			z_index = 10
			shadow_sprite.z_index = -10
		State.DRAGGED: 
			scale = Vector2.ONE * 1.2
			z_index = 10
			shadow_sprite.z_index = 9
			card_holder.card_lay_area.mouse_exited.connect(_scale_to_camera_sized)
			card_holder.card_lay_area.mouse_entered.connect(_unscale)

	if _previous == State.DRAGGED:
		if _state != State.PLACED: 
			_scale_to_camera = false
		card_holder.card_lay_area.mouse_exited.disconnect(_scale_to_camera_sized)
		card_holder.card_lay_area.mouse_entered.disconnect(_unscale)

func _scale_to_camera_sized():
	_scale_to_camera = true
	_insta_scale = false

func _unscale():
	_scale_to_camera = false
	target_scale = Vector2.ONE
	_insta_scale = false
