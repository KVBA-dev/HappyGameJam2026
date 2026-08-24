class_name HexGrid extends Node2D

@onready var hexes_node: Node2D = %HexesNode
@onready var root_hex: Hex = %RootHex
var hex_map: Dictionary[HexVector, Hex] = {}
signal hex_changed(hex: Hex)

func _ready():
	GameManager.hex_grid = self
	hex_map[HexVector.ZERO] = root_hex

func surround_with_hexes(radius: int):
	var blank = preload("res://const_data/hexes/blank_hex.tres")

	for direction: HexVector in HexVector.DIRECTION_MAP.values():
		for i in range(radius):
			var hex_vec = direction.mult(i+1)
			spawn_hex_at(hex_vec, blank)

			for j in range(radius-i):
				var final = hex_vec.add(direction.rotated(1).mult(j))
				spawn_hex_at(final, blank)



func get_hex_at(_position: HexVector) -> Hex:
	return hex_map.get(_position, null)

func clear_hex_at(_position: HexVector):
	if not hex_map.has(_position):
		return false

	hex_map.erase(_position)
	return true

func spawn_hex_at(_position: HexVector, hex_type: HexData) -> Hex:
	if hex_map.has(_position):
		ErrorBus.hex_already_exist_on_position.emit(_position)
		return
	
	var new_hex := Hex.new_instance(_position, hex_type)
	hexes_node.add_child(new_hex)
	hex_map[_position] = new_hex
	hex_changed.emit(new_hex)
	return new_hex
