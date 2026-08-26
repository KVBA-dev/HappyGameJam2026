class_name FactoryHex extends Hex

@onready var production_timer: Timer = %ProductionTimer
var in_production := false
var storage: Dictionary[ItemData, int]
var recipe: Recipe

static func new_instance(
	_hex_position: HexVector,
	_hex_data: HexData,
	appear_style: Hex.AppearStyle = Hex.AppearStyle.Above,
) -> Hex:
	const SCENE := preload("uid://bfcndkssg7rys")
	var new_hex: Hex = SCENE.instantiate()
	new_hex.hex_data = _hex_data
	new_hex.hex_position = _hex_position
	new_hex.position = _hex_position.to_pixel()
	new_hex._appear_style = appear_style
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

func on_item_input(item: Item):
	if item.item_data in recipe.requirements:
		consume(item.item_data)

func consume(item: ItemData):
	storage[item] += 1

	if in_production or not _is_enough_in_storage():
		return

	# If enough in storage
	_start_production()
    
func _is_enough_in_storage() -> bool:
	for requirement: ItemData in recipe.requirements.keys():
		if storage[requirement] < recipe.requirements[requirement]:
			return false
	return true

func _start_production():
	for requirement: ItemData in recipe.requirements.keys():
		storage[requirement] -= recipe.requirements[requirement]

	in_production = true
	production_timer.start()


func produce():
	in_production = false

	_spawn_product()
	if _is_enough_in_storage():
		_start_production()

func _spawn_product():
	## TODO: Implement spawning product
	pass