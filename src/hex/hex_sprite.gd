class_name HexSprite extends Node2D

@onready var background_sprite: Sprite2D = %BackgroundSprite
@onready var on_hex_sprite: Sprite2D = %OnHexSprite
@onready var below_sprite: Sprite2D = %BelowSprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func init(hex_data: HexData):
	background_sprite.texture = hex_data.texture
	on_hex_sprite.texture = hex_data.on_surface_texture
	below_sprite.texture = hex_data.below_texture
	if hex_data.type == HexData.Type.FLOW:
		on_hex_sprite.material = HexData.river_material
		on_hex_sprite.scale = Vector2(0.561, 0.561)
	else:
		on_hex_sprite.material = null
		on_hex_sprite.scale = Vector2(0.366, 0.366)

@onready var _rotate_timer: Timer = %RotateTimer
@onready var _below_displacement: Node2D = %BelowDisplacement
@onready var _bg_displacement: Node2D = %BgDisplacement
var _is_rotating: bool = false
var _displace_tween: Tween
var _rotation_tween: Tween
var _n_60degree_rotations: int = 0
var n_60degree_rotations: int:
	get: return _n_60degree_rotations

func insta_rotate(n_60degree: int) -> void:
	_n_60degree_rotations += n_60degree
	_bg_displacement.rotation = _n_60degree_rotations * PI / 3.0

func rotate_left() -> void:
	_n_60degree_rotations -= 1
	if animation_player.is_playing():
		_rotate_timer.stop()
		animation_player.stop()
		animation_player.play("rotate_left_continue")
	else:
		animation_player.play("rotate_left")

func rotate_right() -> void:
	_n_60degree_rotations += 1
	if animation_player.is_playing():
		_rotate_timer.stop()
		animation_player.stop()
		animation_player.play("rotate_right_continue")
	else:
		animation_player.play("rotate_right")

func _on_animation_started(_anim_name: String) -> void:
	if _anim_name.contains("rotate"):
		_is_rotating = true
		_rotate_timer.start()

		if _rotation_tween:
			_rotation_tween.kill()

		var saved_rot = _bg_displacement.rotation
		_rotation_tween = get_tree().create_tween()
		_rotation_tween.tween_method(func(weight: float):
			_bg_displacement.rotation = lerp_angle(
				saved_rot, 
				_n_60degree_rotations * PI/3, weight),
			0.0, 1.0, 0.24
		)

func _on_rotate_timer_timeout() -> void:
	_is_rotating = false
	if animation_player.is_playing() \
		and animation_player.current_animation.ends_with("continue"):
		if _displace_tween:
			_displace_tween.kill()

		_below_displacement.visible = true
		_displace_tween = get_tree().create_tween()
		_displace_tween.set_trans(Tween.TRANS_CUBIC)
		_displace_tween.set_ease(Tween.EASE_OUT)
		_displace_tween.tween_method(func(pos_y: float):
			_below_displacement.position.y = pos_y,
			-80.0, 0.0, 0.24
		)
