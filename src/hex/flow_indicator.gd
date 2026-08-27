class_name FlowIndicator extends Sprite2D


@onready var mouse_area = %MouseArea

var direction: HexVector.Direction

func _ready() -> void:
	mouse_area.mouse_entered.connect(_block_selection)
	mouse_area.mouse_exited.connect(_unblock_selection)

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

func _block_selection():
	GameManager.main.cursor.block_selection = true

func _unblock_selection():
	GameManager.main.cursor.block_selection = false
