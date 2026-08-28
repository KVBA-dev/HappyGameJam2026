class_name HoverableArea extends Area2D

var _hover: bool = false
var hover: bool:
	get:
		return _hover

func _ready() -> void:
	mouse_entered.connect(_on_area_2d_mouse_entered)
	mouse_exited.connect(_on_area_2d_mouse_exited)

func _on_area_2d_mouse_entered() -> void:
	_hover = true

func _on_area_2d_mouse_exited() -> void:
	_hover = false
