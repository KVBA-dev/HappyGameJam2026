class_name FactoryHex extends Hex

@onready var production_timer: Timer = %ProductionTimer
@onready var direction_indicator: Sprite2D = %DirectionIndicator

var in_production := false
var storage: Dictionary[ItemData, int]
var recipe: Recipe
var paths: Array[PathData] = []

static func new_instance(
	_hex_position: HexVector,
	_hex_data: HexData,
	appear_style: Hex.AppearStyle = Hex.AppearStyle.Above,
) -> Hex:
	const SCENE := preload("uid://bfcndkssg7rys")
	var new_hex: Hex = SCENE.instantiate()
	new_hex.init_data(_hex_position, _hex_data, appear_style)
	return new_hex


func _ready() -> void:
	super._ready()
	if not hex_data.recipe:
		push_error("Recipe has to be set for factory hex")
	if not hex_data.item_flow:
		push_error("Flow has to be set for factory hex")

	recipe = hex_data.recipe
	for item: ItemData in recipe.requirements.keys():
		storage[item] = 0
	production_timer.wait_time = recipe.processing_time
	production_timer.timeout.connect(produce)
	GameManager.paths.path_created.connect(_on_path_created)
	GameManager.paths.path_deleted.connect(_on_path_deleted)

func _process(_delta: float) -> void:
	if GameManager.paths.start_hex == self:
		show_indicator(GameManager.paths.start_dir)
	elif is_mouse_inside:
		show_indicator(_mouse_dir())
	else:
		direction_indicator.hide()

# TODO: Do dodania stany - jak nie jest wybrany start_hex to wskazujemy poprawne outputy - strzałka wychodząca.
# Jeżeli start_hex wybrany i mamy najechany inny niż start_hex hex to wskazujemy inputy jako poprawne - strzałka wchodząca.
func show_indicator(dir: HexVector.Direction):
	if dir in hex_data.item_flow.outputs:
		direction_indicator.modulate = Color(0xffffffff)
	else:
		direction_indicator.modulate = Color(0xff000066)
	direction_indicator.position = Vector2(64,0).rotated(HexVector.dir_to_angle(dir))
	direction_indicator.show()


func _on_path_created(path_data: PathData):
	paths.append(path_data)
	_start_production()
	

func _on_path_deleted(path_data: PathData):
	paths.erase(path_data)

func on_item_input(item: Item):
	if item.item_data in recipe.requirements:
		consume(item.item_data)

func consume(item: ItemData):
	storage[item] += 1
	_start_production()
	
func _is_enough_in_storage() -> bool:
	for requirement: ItemData in recipe.requirements.keys():
		if storage[requirement] < recipe.requirements[requirement]:
			return false
	return true

func _start_production():
	if in_production or not _is_enough_in_storage():
		return
	in_production = true
	production_timer.start()


func produce():
	in_production = false

	_spawn_product()
	if _is_enough_in_storage():
		_start_production()

func _spawn_product():
	for requirement: ItemData in recipe.requirements.keys():
		storage[requirement] -= recipe.requirements[requirement]
	
	GameManager.paths.spawn_item_on_path(recipe.produces, paths.pick_random())
