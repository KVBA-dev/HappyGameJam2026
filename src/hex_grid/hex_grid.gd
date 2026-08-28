class_name HexGrid extends Node2D

@onready var hexes_node: Node2D = %HexesNode
@onready var root_hex: Hex = %RootHex
var hex_map: Dictionary[Vector2i, Hex] = {}
signal spawned_hex(hex: Hex)
signal deleted_hex(position: HexVector)
signal changed_hex(old_hex: Hex, new_hex: Hex)
signal rotated_hex(hex: Hex, new_rotation: HexVector.Direction)

const BLANK: HexData = preload("res://const_data/hexes/blank_hex.tres")

func _ready():
	GameManager.hex_grid = self

	SignalBus.card_used.connect(handle_card_placed)
	spawned_hex.connect(_on_hex_spawned)
	
	reset_grid()

func reset_grid() -> void:
	for hex: Hex in hex_map.values():
		if hex == root_hex:
			continue
		hex.queue_free()
	hex_map.clear()
	hex_map[HexVector.ZERO.vec] = root_hex

func surround_with_hexes(radius: int, center: HexVector = HexVector.ZERO):
	for direction: HexVector in HexVector.DIRECTION_MAP.values():
		for i in range(radius):
			var hex_vec = direction.mult(i+1)

			for j in range(radius-i):
				var final = hex_vec.add(direction.rotated(1).mult(j))
				final = final.add(center)

				if get_hex_at(final) != null:
					continue

				spawn_hex_at(final, BLANK, Hex.AppearStyle.Below)

func get_hex_at(_position: HexVector) -> Hex:
	return hex_map.get(_position.vec, null)

func get_random_blank_hex_in_spawn_range() -> Hex:
	var non_blank_hexes: Array[Hex] = []
	var candidates: Array[Hex] = []

	for hex: Hex in hex_map.values():
		if hex.hex_data.type != HexData.Type.BLANK:
			non_blank_hexes.append(hex)

	if non_blank_hexes.is_empty():
		non_blank_hexes.push_back(get_hex_at(HexVector.new(0, 0)))

	for hex: Hex in hex_map.values():
		if hex.hex_data.type != HexData.Type.BLANK:
			continue

		var closest_distance: int = 1_000_000
		for non_blank_hex: Hex in non_blank_hexes:
			closest_distance = min(
				closest_distance,
				hex.hex_position.distance_to(non_blank_hex.hex_position),
			)

		if closest_distance > 2 and closest_distance <= 3:
			candidates.append(hex)

	if candidates.is_empty():
		return null
	return candidates.pick_random()

func get_hex_neighbours(_position: HexVector) -> Array[Hex]:
	var ret: Array[Hex] = []
	for neighbour_pos: HexVector in _position.get_all_neighbors():
		var neighbour := get_hex_at(neighbour_pos)
		if neighbour:
			ret.push_back(neighbour)
	return ret

func clear_hex_at(_position: HexVector):
	deleted_hex.emit(_position)
	if not hex_map.has(_position.vec):
		return false

	hex_map[_position.vec].animated_kill()
	hex_map.erase(_position.vec)
	return true

func _can_place_at(_position: HexVector) -> bool:
	var existing_hex := get_hex_at(_position)
	if existing_hex and existing_hex.type != HexData.Type.BLANK:
		return false

	return true

func spawn_hex_at(_position: HexVector, hex_type: HexData, appear_style: Hex.AppearStyle = Hex.AppearStyle.Instant) -> Hex:
	if not _can_place_at(_position):
		return

	var new_hex := instantiate_hex(_position, hex_type, appear_style)
	hexes_node.add_child(new_hex)
	hex_map[_position.vec] = new_hex
	spawned_hex.emit(new_hex)
	return new_hex

func spawn_hex_from_card(
		_position: HexVector, 
		card: CardHudBase, 
		appear_style: Hex.AppearStyle = Hex.AppearStyle.Instant
	) -> Hex:
	if not _can_place_at(_position):
		return

	var new_hex := instantiate_hex(_position, card.card_data.hex_data, appear_style)

	hexes_node.add_child(new_hex)
	new_hex.rotate_hex(card.n_60degree_rotations)
	hex_map[_position.vec] = new_hex
	spawned_hex.emit(new_hex)
	return new_hex



func instantiate_hex(
	_position: HexVector,
	hex_type: HexData,
	appear_style: Hex.AppearStyle = Hex.AppearStyle.Instant,
) -> Hex:
	match hex_type.type:
		HexData.Type.FLOW:
			return FlowHex.new_instance(_position, hex_type, appear_style)
		HexData.Type.FACTORY:
			return FactoryHex.new_instance(_position, hex_type, appear_style)
		HexData.Type.BLANK:
			return Hex.new_instance(_position, hex_type, appear_style)
		_:
			push_error("Instantiation of a hex not implemented")
			return

func handle_card_placed(data: CardHudBase, pos: HexVector):
	if data.card_data.type == CardData.Type.PLACABLE:
		clear_hex_at(pos)
		spawn_hex_from_card(pos, data, Hex.AppearStyle.Above)
	elif data.card_data.type == CardData.Type.USABLE:
		var usable_card: UsableCardData = data.card_data
		match usable_card.usable_type:
			UsableCardData.UsableType.BACK_TO_HAND:
				var _hex: Hex = get_hex_at(pos)
				if _hex:
					var returned_card := CardData.new()
					returned_card.type = CardData.Type.PLACABLE
					returned_card.hex_data = _hex.hex_data
					GameManager.card_holder.queue_add_card(returned_card)
					clear_hex_at(pos)
					spawn_hex_at(pos, BLANK)
			UsableCardData.UsableType.DELETE:
				clear_hex_at(pos)
				spawn_hex_at(pos, BLANK)
			UsableCardData.UsableType.DUPLICATE:
				var _hex: Hex = get_hex_at(pos)
				if _hex:
					var returned_card := CardData.new()
					returned_card.type = CardData.Type.PLACABLE
					returned_card.hex_data = _hex.hex_data
					GameManager.card_holder.queue_add_card(returned_card)

func _on_hex_spawned(hex: Hex):
	var data := hex.hex_data
	if not data.should_surround_by_blanks():
		return

	surround_with_hexes(3, hex.hex_position)

func can_place_card(card: CardHudBase, pos: HexVector, log_errors: bool = true) -> bool:
	var is_any_neighbour_non_blank := false
	for neighbour: Hex in get_hex_neighbours(pos):
		if neighbour.hex_data.type != HexData.Type.BLANK:
			is_any_neighbour_non_blank = true
			break

	if not is_any_neighbour_non_blank:
		if log_errors: ErrorBus.hex_too_far_from_existing.emit(pos)
		return false

	var makes_valid_path := false
	var flow: Flow = card.card_data.hex_data.item_flow.duplicate_deep()
	flow.rotate(card.n_60degree_rotations)

	for vec: HexVector in flow.get_input_tiles(pos):
		var hex := get_hex_at(vec)
		if not hex or not hex.item_flow: continue
		if pos.in_arr(hex.item_flow.get_output_tiles(hex.hex_position)):
			makes_valid_path = true
			break

	for vec: HexVector in flow.get_output_tiles(pos):
		var hex := get_hex_at(vec)
		if not hex or not hex.item_flow: continue
		if pos.in_arr(hex.item_flow.get_input_tiles(hex.hex_position)):
			makes_valid_path = true
			break

	if not makes_valid_path:
		if log_errors: ErrorBus.hex_misses_valid_path.emit(pos)
		return false

	return makes_valid_path
