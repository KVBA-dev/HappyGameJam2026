class_name FactoryHex extends Hex

@onready var indicator_container: Node2D = %IndicatorContainer
@onready var in_out_hint: Sprite2D = %InOutHint

var MODULATE_INPUT := Color.hex(0x0044ff64)
var MODULATE_OUTPUT := Color.hex(0xff000032)
var _is_hinting := false

var recipe: Recipe
var paths: Array[PathData] = []
var ticks: int
var connected := BoolSF.new()

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
	if not item_flow:
		push_error("Flow has to be set for factory hex")
	GameManager.main.factories.append(self)
	_generate_indicators()

	SignalBus.hex_selected.connect(_show_input_output_hint)
	SignalBus.hex_deselected.connect(_hide_input_output_hint)

	recipe = hex_data.recipe
	ticks = recipe.processing_time_ticks
	SignalBus.game_timer_tick.connect(tick)
	GameManager.paths.path_created.connect(_on_path_created)
	GameManager.paths.path_deleted.connect(_on_path_deleted)

func indicator_container_show_only_inputs():
	for child: FlowIndicator in indicator_container.get_children():
		child.visible = child.is_input
	indicator_container.show()

func indicator_container_show_all():
	for child: FlowIndicator in indicator_container.get_children():
		child.visible = true
	indicator_container.show()

func _process(_delta: float) -> void:
	if _is_hinting and GameManager.paths.start_hex:
		indicator_container_show_only_inputs()
	elif (
		CursorSelect.selected == self \
		or GameManager.paths.start_hex == self
	):
		indicator_container_show_all()
	else:
		indicator_container.hide()

func _show_input_output_hint(hex: Hex):
	if hex is not FactoryHex:
		return

	if (hex as FactoryHex).recipe.requirements.has(recipe.produces):
		in_out_hint.show()
		in_out_hint.modulate = MODULATE_INPUT
	elif recipe.requirements.has(hex.recipe.produces):
		in_out_hint.show()
		in_out_hint.modulate = MODULATE_OUTPUT
		_is_hinting = true

func _hide_input_output_hint(hex: Hex):
	if hex is not FactoryHex:
		return

	in_out_hint.hide()
	_is_hinting = false

func _on_path_created(path_data: PathData):
	if path_data.start == self:
		paths.append(path_data)
	_update_connected()

func _on_path_deleted(path_data: PathData):
	paths.erase(path_data)
	_update_connected()

func _update_connected() -> void:
	var requirements := recipe.requirements.keys()
	if requirements.is_empty():
		connected.value = true
		SignalBus.factory_connected.emit(self)
	for path_data: PathData in GameManager.paths.paths:
		if path_data.end == self:
			requirements.erase(path_data.start.recipe.produces)
		if requirements.is_empty():
			connected.value = true
			SignalBus.factory_connected.emit(self)
			return
	connected.value = false

func on_item_input(item: Item):
	if item.item_data in recipe.requirements:
		item.get_consumed()

	
func tick():
	if not connected.value:
		return
	ticks -= 1
	if ticks == 0:
		ticks = recipe.processing_time_ticks
		produce()

func produce():
	if not connected.value:
		return

	_spawn_product()

var carousel_selection: int = 0
func _spawn_product():
	if not paths.is_empty():
		GameManager.paths.spawn_item_on_path(recipe.produces, paths[carousel_selection % len(paths)])
		carousel_selection += 1
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
	indicator_container_show_all()
