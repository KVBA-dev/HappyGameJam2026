class_name FactoryHex extends Hex

@onready var direction_indicator: Sprite2D = %DirectionIndicator
@onready var indicator_container: Node2D = %IndicatorContainer

var in_production := false
var storage: Dictionary[ItemData, int]
var recipe: Recipe
var paths: Array[PathData] = []
var ticks: int

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

	_generate_indicators()

	recipe = hex_data.recipe
	ticks = recipe.processing_time_ticks
	for item: ItemData in recipe.requirements.keys():
		storage[item] = 0
	SignalBus.game_timer_tick.connect(tick)
	GameManager.paths.path_created.connect(_on_path_created)
	GameManager.paths.path_deleted.connect(_on_path_deleted)

func _process(_delta: float) -> void:
	if CursorSelect.selected == self:
		indicator_container.show()
	elif GameManager.paths.start_hex == self:
		indicator_container.show()
	else:
		indicator_container.hide()

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
	if path_data.start == self:
		paths.append(path_data)
		_start_production()
	

func _on_path_deleted(path_data: PathData):
	paths.erase(path_data)

func on_item_input(item: Item):
	if item.item_data in recipe.requirements:
		consume(item.item_data)
		item.get_consumed()

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

func tick():
	if not in_production:
		return
	ticks -= 1
	if ticks == 0:
		ticks = recipe.processing_time_ticks
		produce()

func produce():
	in_production = false

	_spawn_product()
	if _is_enough_in_storage():
		_start_production()

func _spawn_product():
	for requirement: ItemData in recipe.requirements.keys():
		storage[requirement] -= recipe.requirements[requirement]
	
	GameManager.paths.spawn_item_on_path(recipe.produces, paths.pick_random())
	SignalBus.item_produced.emit(recipe.produces)

func _generate_indicators():
	for direction: HexVector.Direction in item_flow.inputs:
		var indi := FlowIndicator.new_instance(self, direction, true)
		indicator_container.add_child(indi)

	for direction: HexVector.Direction in item_flow.outputs:
		var indi := FlowIndicator.new_instance(self, direction, false)
		indicator_container.add_child(indi)

# Override
func select():
	indicator_container.show()
