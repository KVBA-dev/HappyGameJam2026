class_name HexGrid extends Node2D

@onready var hexes_node: Node2D = %HexesNode
@onready var root_hex: Hex = %RootHex
var hex_map: Dictionary[HexVector, Hex] = {}
signal hex_changed(hex: Hex)

func _ready():
	GameManager.hex_grid = self
	hex_map[HexVector.ZERO] = root_hex

	SignalBus.card_used.connect(handle_card_placed)

func surround_with_hexes(radius: int):
	var blank = preload("res://const_data/hexes/blank_hex.tres")

	for direction: HexVector in HexVector.DIRECTION_MAP.values():
		for i in range(radius):
			var hex_vec = direction.mult(i+1)
			spawn_hex_at(hex_vec, blank.duplicate())

			for j in range(radius-i-1):
				var final = hex_vec.add(direction.rotated(1).mult(j+1))
				spawn_hex_at(final, blank.duplicate())

func get_hex_at(_position: HexVector) -> Hex:
	return hex_map.get(_position, null)

func clear_hex_at(_position: HexVector):
	if not hex_map.has(_position):
		return false

	hex_map[_position].queue_free()
	hex_map.erase(_position)
	return true

func spawn_hex_at(_position: HexVector, hex_type: HexData) -> Hex:
	if hex_map.has(_position):
		ErrorBus.hex_already_exist_on_position.emit(_position)
		return
	var new_hex := instantiate_hex(_position, hex_type)
	hexes_node.add_child(new_hex)
	hex_map[_position] = new_hex
	hex_changed.emit(new_hex)
	return new_hex


func instantiate_hex(_position: HexVector, hex_type: HexData) -> Hex:
	match hex_type.type:
		HexData.Type.FLOW:
			return FlowHex.new_instance(_position, hex_type)
		HexData.Type.FACTORY:
			return FactoryHex.new_instance(_position, hex_type)
		HexData.Type.BLANK:
			return Hex.new_instance(_position, hex_type)
		_:
			push_error("Instantiation of a hex not implemented")
			return

func handle_card_placed(data: CardData, pos: HexVector):
	clear_hex_at(pos)
	spawn_hex_at(pos, data.hex_data)
