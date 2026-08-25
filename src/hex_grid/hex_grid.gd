class_name HexGrid extends Node2D

@onready var hexes_node: Node2D = %HexesNode
@onready var root_hex: Hex = %RootHex
var hex_map: Dictionary[Vector2i, Hex] = {}
signal hex_changed(hex: Hex)

func _ready():
	GameManager.hex_grid = self
	hex_map[HexVector.ZERO.vec] = root_hex

	SignalBus.card_used.connect(handle_card_placed)
	hex_changed.connect(_on_hex_changed)

func surround_with_hexes(radius: int, center: HexVector = HexVector.ZERO):
	var blank = preload("res://const_data/hexes/blank_hex.tres")

	for direction: HexVector in HexVector.DIRECTION_MAP.values():
		for i in range(radius):
			var hex_vec = direction.mult(i+1)

			for j in range(radius-i):
				var final = hex_vec.add(direction.rotated(1).mult(j))
				final = final.add(center)

				if get_hex_at(final) != null:
					continue

				spawn_hex_at(final, blank.duplicate(), Hex.AppearStyle.Below)

func get_hex_at(_position: HexVector) -> Hex:
	return hex_map.get(_position.vec, null)

func get_hex_neighbours(_position: HexVector) -> Array[Hex]:
	var ret: Array[Hex] = []
	for neighbour_pos: HexVector in _position.get_all_neighbors():
		var neighbour := get_hex_at(neighbour_pos)
		if neighbour:
			ret.push_back(neighbour)
	return ret

func clear_hex_at(_position: HexVector):
	if not hex_map.has(_position.vec):
		return false

	hex_map[_position.vec].animated_kill()
	hex_map.erase(_position.vec)
	return true

func spawn_hex_at(_position: HexVector, hex_type: HexData, appear_style: Hex.AppearStyle = Hex.AppearStyle.Instant) -> Hex:
	if hex_map.has(_position.vec):
		ErrorBus.hex_already_exist_on_position.emit(_position)
		print("overlap")
		return

	var new_hex := Hex.new_instance(_position, hex_type, appear_style)
	hexes_node.add_child(new_hex)
	hex_map[_position.vec] = new_hex
	hex_changed.emit(new_hex)
	return new_hex

func handle_card_placed(data: CardData, pos: HexVector):
	clear_hex_at(pos)
	spawn_hex_at(pos, data.hex_data, Hex.AppearStyle.Above)

func _on_hex_changed(hex: Hex):
	var data := hex.hex_data
	if not data.should_surround_by_blanks():
		return

	surround_with_hexes(3, hex.hex_position)
