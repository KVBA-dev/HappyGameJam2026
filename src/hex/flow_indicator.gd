class_name FlowIndicator extends Sprite2D

@onready var mouse_area = %MouseArea

static var MODULATE_INPUT = Color.hex(0x008cffff)
static var MODULATE_OUTPUT = Color.hex(0xe55400ff)
static var MODULATE_SELECTED = Color.hex(0xf9e9adff)

var direction: HexVector.Direction
var hex: FactoryHex
var is_input: bool

func _ready() -> void:
	mouse_area.mouse_entered.connect(_block_selection)
	mouse_area.mouse_exited.connect(_unblock_selection)

static func new_instance(hex_: FactoryHex, dir: HexVector.Direction, is_input_: bool) -> FlowIndicator:
	const SCENE = preload("uid://dai4s6gx18ivu")
	var scene: Sprite2D = SCENE.instantiate()

	var vec = HexVector.direction_vector(dir)
	var pos = vec.to_pixel().normalized() * 100

	scene.position = pos
	scene.rotation = pos.angle()
	if is_input_: 
		scene.rotation += PI
		scene.modulate = MODULATE_INPUT
	else:
		scene.modulate = MODULATE_OUTPUT

	scene.direction = dir
	scene.hex = hex_
	scene.is_input = is_input_
	return scene

func _modulate():
	if GameManager.paths.start_hex == hex and GameManager.paths.start_dir == direction:
		modulate = MODULATE_SELECTED
	else:
		modulate = MODULATE_INPUT if is_input else MODULATE_OUTPUT

func _process(delta: float) -> void:
	_modulate()
	var target_scale = Vector2.ONE
	if mouse_area.hover:
		target_scale *= 1.2

	const SCALE_SPEED = 10.0
	scale = Vector2(
		Utils.smooth_exp(scale.x, target_scale.x, SCALE_SPEED, delta),
		Utils.smooth_exp(scale.y, target_scale.y, SCALE_SPEED, delta)
	)

	if Input.is_action_just_pressed("select_hex") \
		and mouse_area.hover:
		SignalBus.hex_factory_clicked.emit(hex, direction)

func _block_selection():
	GameManager.main.cursor.block_selection = true

func _unblock_selection():
	GameManager.main.cursor.block_selection = false
