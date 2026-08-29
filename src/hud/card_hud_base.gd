class_name CardHudBase extends Node2D

@onready var shadow_sprite: Sprite2D = %ShadowSprite

const MIN_Z_INDEX = 0
const BASE_SCALE = 1.5 * Vector2.ONE

var infinite_card: BoolSF = BoolSF.new()

enum State {
	IN_HAND = 0,
	PREVIEWED = 1,
	DRAGGED = 2,
	PLACED = 3
}

var n_60degree_rotations: int:
	get:
		return hex_sprite.n_60degree_rotations

var target_pos: Vector2 = self.position
var target_scale: Vector2 = BASE_SCALE
var card_data: CardData

var _scale_to_camera: bool = false
var _insta_scale: bool = false

@onready var hex_sprite: HexSprite = %HexSprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer
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

func _ready() -> void:
	infinite_card.changed.connect(func(val: bool):
		hex_sprite.rainbow_border_sprite.visible = val
	)

func _process(delta: float) -> void:
	match _state:
		State.IN_HAND: _in_hand_processed(delta)
		State.PREVIEWED: _previewed_process(delta)
		State.DRAGGED: _dragged_process(delta)

func _in_hand_processed(delta: float):
	var offset := Vector2.ZERO
	if infinite_card.value:
		offset.y = sin(Time.get_ticks_msec() / 1000.0) * 20.0

	const MOVE_SPEED = 5.0
	position = Vector2(
		Utils.smooth_exp(position.x, target_pos.x + offset.x, MOVE_SPEED, delta),
		Utils.smooth_exp(position.y, target_pos.y + offset.y, MOVE_SPEED, delta)
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
			scale = BASE_SCALE 
		State.PREVIEWED:
			scale = BASE_SCALE * 1.2
			rotation = 0
			z_index = 10
		State.DRAGGED: 
			scale = BASE_SCALE * 1.2
			z_index = 100
			card_holder.card_lay_area.mouse_exited.connect(_scale_to_camera_sized)
			card_holder.card_lay_area.mouse_entered.connect(_unscale)
		State.PLACED: 
			hex_sprite.z_index = 1
			shadow_sprite.z_index = 0

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
	target_scale = BASE_SCALE
	_insta_scale = false

# Virtual
func start_use_animation():
	push_warning("Base card hud highlight shouldn't be used")
	queue_free()

func _reparent_node_for_animation() -> void:
	var screen_pos = card_holder.cards_container.to_global(position)
	reparent(GameManager.hex_grid.hexes_node)

	position = GameManager.hex_grid.get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	scale = Vector2.ONE

func match_rotations(other: CardHudBase) -> void:
	hex_sprite.reset_rotation()
	hex_sprite.insta_rotate(other.n_60degree_rotations)

func rotate_left():
	SignalBus.card_rotated.emit(self)
	hex_sprite.rotate_left()

func rotate_right():
	SignalBus.card_rotated.emit(self)
	hex_sprite.rotate_right()

func _copy_to_hand_holder(is_binned: bool = false):
	var added := card_holder._add_card(card_data) # Force add card
	added.infinite_card.value = infinite_card.value
	added.global_position = card_holder.infinite_card_pos.global_position
	added.match_rotations(self)
	if not is_binned: added.animation_player.play("spawn_infinite")
	#else: added.animation_player.play("spawn_infinite_bin")

func _animated_delete():
	hex_sprite.animation_player.play("remove")
	hex_sprite.animation_player.animation_finished.connect(func(s: String):
		if s == "remove":
			queue_free()
	)

func on_trash():
	if not infinite_card.value:
		_animated_delete()
		return

	card_data = GameManager.infinites.carousel_pick()
	hex_sprite.init(card_data.hex_data)
	card_holder.cards.push_front(self)
