class_name Camera
extends Camera2D

var zoom_level: float = 1

var target_position := Vector2.ZERO
var target_zoom := 0.0

const SMOOTHING: float = 8.5
const CAMERA_SPEED: float = 8.0
const ZOOM_SPEED: float = 0.3

func _ready() -> void:
	target_position = position
	target_zoom = zoom_level

func _get_axis(pos: String, neg: String, proc: Callable = Input.is_action_pressed) -> float:
	var axis: float = 0
	axis += 1 if proc.call(pos) else 0
	axis -= 1 if proc.call(neg) else 0
	return axis

func _process(_delta: float) -> void:
	var axis_horizontal := _get_axis("camera_right", "camera_left")
	var axis_vertical := _get_axis("camera_down", "camera_up")
	var axis_zoom := _get_axis("camera_zoom_in", "camera_zoom_out", Input.is_action_just_released)
	
	target_position += CAMERA_SPEED * Vector2(axis_horizontal, axis_vertical)
	target_zoom = clamp(target_zoom + axis_zoom * ZOOM_SPEED, 0.5, 6)
	
	position = lerp(position, target_position, SMOOTHING * _delta)
	zoom_level = lerpf(zoom_level, target_zoom, SMOOTHING * _delta)
	zoom = Vector2(zoom_level, zoom_level)
