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
	SignalBus.go_unconnected.connect(go_unconnected)

func _get_axis(pos: String, neg: String, proc: Callable = Input.is_action_pressed) -> float:
	var axis: float = 0
	axis += 1 if proc.call(pos) else 0
	axis -= 1 if proc.call(neg) else 0
	return axis

var last_mouse_pos: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	var axis_horizontal := _get_axis("camera_right", "camera_left")
	var axis_vertical := _get_axis("camera_down", "camera_up")
	var axis_zoom := _get_axis("camera_zoom_in", "camera_zoom_out", Input.is_action_just_released)
	
	var mouse_pos := get_viewport().get_mouse_position()
	var mouse_vel = mouse_pos - last_mouse_pos
	last_mouse_pos = mouse_pos
	if Input.is_action_pressed("camera_drag"):
		target_position -= mouse_vel / zoom_level
	else:
		target_position += CAMERA_SPEED / min(target_zoom, 1.0) * Vector2(axis_horizontal, axis_vertical)
	target_zoom = clamp(target_zoom + axis_zoom * ZOOM_SPEED, 0.25, 2)
	
	position = lerp(position, target_position, SMOOTHING * _delta)
	var prev_zoom_level = zoom_level
	zoom_level = lerpf(zoom_level, target_zoom, SMOOTHING * _delta)
	AudioSystem.instance.wind_volume = abs(zoom_level - prev_zoom_level)
	zoom = Vector2(zoom_level, zoom_level)


func go_unconnected():
	target_position = GameManager.hex_grid.get_next_unconnected_factory().global_position
