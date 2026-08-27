class_name HudMessage extends Node2D

@onready var panel: Panel = %Panel
@onready var container: PanelContainer = %Container
@onready var content: Control = %Content
@onready var clip_container: Control = %ClipContainer
@onready var label: Label = %Label

var _currently_showing: bool = false
var currently_showing: bool:
	get:
		return _currently_showing

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	scale = Vector2.ONE / get_viewport().get_camera_2d().zoom

func show_text(text: String):
	label.text = text
	slide_in()

func is_anim_playing():
	return _tween and _tween.is_running()

var _tween: Tween
func slide_in():
	_tween = get_tree().create_tween()
	var min_size := calculate_size() + Vector2(10, 10)
	clip_container.position.y = -min_size.y

	clip_container.size = min_size
	clip_container.size.x = 0.0

	show()
	_tween.set_trans(Tween.TRANS_EXPO)
	_tween.tween_property(clip_container, "size", min_size, 0.5)
	_currently_showing = true

func slide_out():
	_tween = get_tree().create_tween()
	show()
	var hide_size := calculate_size() + Vector2(10, 10)
	clip_container.position.y = -hide_size.y

	hide_size.x = 0
	_tween.set_trans(Tween.TRANS_EXPO)
	_tween.tween_property(clip_container, "size", hide_size, 0.5)
	_tween.finished.connect(func(): queue_free())
	_currently_showing = false

func calculate_size() -> Vector2:
	content.reparent(container)
	var min_size = container.get_combined_minimum_size()
	content.reparent(panel)
	return min_size
