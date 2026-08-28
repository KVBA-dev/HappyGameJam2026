class_name PathLine extends Path2D

@onready var visual_line: Line2D = %VisualLine
var waypoints: Array[Hex] = []


static func new_instance(_waypoints: Array[Hex]) -> PathLine:
	const SCENE := preload("uid://ckylfobiilnk6")
	var path_line: PathLine = SCENE.instantiate()
	path_line.waypoints = _waypoints
	return path_line

func _ready() -> void:
	curve = Curve2D.new()

	var waypoints_positions := waypoints.map(func(hex: Hex) -> Vector2: return hex.hex_position.to_pixel())
	visual_line.points = PackedVector2Array(waypoints_positions)
	visual_line.default_color = Color.from_rgba8(randi_range(0, 255), randi_range(0, 255), randi_range(0, 255), 255)
	for point: Vector2 in waypoints_positions:
		curve.add_point(point)
	SignalBus.path_visibility_toggled.connect(on_path_visibility_toggled)
	on_path_visibility_toggled(GameManager.main.paths_visible)

func show_line():
	visual_line.show()

func hide_line():
	visual_line.hide()

func on_path_visibility_toggled(paths_visible: bool) -> void:
	if paths_visible: show_line()
	else: hide_line()
