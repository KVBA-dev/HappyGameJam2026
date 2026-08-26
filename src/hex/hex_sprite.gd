class_name HexSprite extends Node2D

@onready var background_sprite: Sprite2D = %BackgroundSprite
@onready var on_hex_sprite: Sprite2D = %OnHexSprite
@onready var below_sprite: Sprite2D = %BelowSprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func init(hex_data: HexData):
	background_sprite.texture = hex_data.texture
	on_hex_sprite.texture = hex_data.on_surface_texture
	below_sprite.texture = hex_data.below_texture



@onready var _rotate_timer: Timer = %RotateTimer
@onready var _below_displacement: Node2D = %BelowDisplacement
var _is_rotating: bool = false
var _displace_tween: Tween

func rotate_left() -> void:
	if animation_player.is_playing():
		_rotate_timer.stop()
		animation_player.stop()
		animation_player.play("rotate_left_continue")
	else:
		animation_player.play("rotate_left")

func rotate_right() -> void:
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
