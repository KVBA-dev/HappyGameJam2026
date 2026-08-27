class_name FlowIndicator extends Sprite2D


@onready var mouse_area = %MouseArea

var direction: HexVector.Direction

static func new_instance(dir: HexVector.Direction, is_input: bool) -> FlowIndicator:
	const SCENE = preload("uid://dai4s6gx18ivu")
	var scene: Sprite2D = SCENE.instantiate()

	var vec = HexVector.direction_vector(dir)
	var pos = vec.to_pixel().normalized() * 100

	scene.position = pos
	scene.rotation = pos.angle()
	if is_input: scene.rotation += PI
	return scene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("select_hex") and mouse_area.hover:
		print("JEJ")

