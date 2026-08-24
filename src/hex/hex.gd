class_name Hex extends Node2D

@export var hex_data: HexData
var hex_position: HexVector
const SCENE := preload("uid://c35v72ubhgdk6")


static func new_instance(_hex_position: HexVector, _hex_data: HexData) -> Hex:
	var new_hex: Hex = SCENE.instantiate()
	new_hex.hex_data = _hex_data
	new_hex.hex_position = _hex_position
	return new_hex

func distance_to(other: HexData) -> int:
	return hex_position.distance_to(other.hex_position)

func get_neighbor(direction: HexVector.Direction) -> Hex:
	return GameManager.hex_grid.get_hex_at(hex_position.add(HexVector.direction_vector(direction)))

func get_neighbors() -> Array[Hex]:
	var neighbors: Dictionary[HexVector.Direction, Hex] = {}
	for direction in HexVector.Direction.values():
		neighbors[direction] = get_neighbor(direction)
	return neighbors.values().filter(func(neighbor): return neighbor != null)
