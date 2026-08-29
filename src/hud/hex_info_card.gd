class_name HexInfoCard extends PanelContainer

@onready var hex_title: Label = %HexTitle
@onready var hex_sprite: HexSprite = %HexSprite
@onready var produces_icon: TextureRect = %ProducesIcon
@onready var needs_col: BoxContainer = %NeedsCol
@onready var needed_row: BoxContainer = %NeededRow

var hex_data: HexData:
	set(value):
		hex_data = value
		_set_data()

func _ready() -> void:
	SignalBus.hex_selected.connect(_on_hex_selected)
	SignalBus.hex_deselected.connect(_on_hex_deselected)

func _on_hex_selected(hex: Hex):
	if hex is FactoryHex:
		hex_data = hex.hex_data
		show()

func _on_hex_deselected(_hex: Hex):
	hide()


func _set_data():
	hex_title.text = hex_data.hex_name
	hex_sprite.init(hex_data)
	produces_icon.texture = hex_data.get_production_texture()
	var requirements := hex_data.get_requirements()
	if requirements.is_empty():
		needs_col.hide()
	else:
		_show_requirements_row(requirements)
		

func _show_requirements_row(requirements: Array[ItemData]):
	for child in needed_row.get_children():
		if child is NeededIcon:
			child.queue_free()
	for requirement: ItemData in requirements:
		var icon := NeededIcon.new_instance(requirement)
		needed_row.add_child(icon)
	needs_col.show()
	
