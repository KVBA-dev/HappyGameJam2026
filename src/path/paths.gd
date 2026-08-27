class_name Paths extends Node

var paths: Array[PathData]
var PATH_LINE_MAP: Dictionary[PathData, PathLine]
var start_hex: FactoryHex
var start_dir: HexVector.Direction

signal path_created(path: PathData)
signal path_deleted(path: PathData)

func _ready() -> void:
	GameManager.paths = self
	GameManager.hex_grid.deleted_hex.connect(_on_hex_deleted)
	SignalBus.hex_factory_clicked.connect(_on_hex_factory_clicked)
	SignalBus.hex_selected.connect(_on_hex_selected)

func _deselect():
	start_hex = null

func _on_hex_selected(hex: Hex):
	if hex == start_hex:
		_deselect()

func _on_hex_factory_clicked(hex: Hex, dir: HexVector.Direction):
	if not hex is FactoryHex:
		return

	if hex == start_hex and dir == start_dir:
		_deselect()
		return

	if dir in hex.item_flow.outputs:
			start_hex = hex
			start_dir = dir

	elif start_hex:
		if not dir in hex.item_flow.inputs:
			return

		# TODO: Make it make sense
		GameManager.main.cursor.cursor_select.deselect()

		var created_path := create_path(start_hex, start_dir, hex, dir)
		if created_path.is_empty():
			start_hex = null
			return
		start_hex = null
		

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cancel"):
		start_hex = null

func _on_hex_deleted(_position: HexVector):
	for path_data: PathData in paths:
		var position_on_path := path_data.waypoints.any(func(value: FlowHex): return value.hex_position.eq(_position))
		if position_on_path:
			_clear_path(path_data)

func _clear_path(path_data: PathData):
	var path_line := PATH_LINE_MAP[path_data]
	PATH_LINE_MAP.erase(path_data)
	path_line.queue_free()
	paths.erase(path_data)
	path_deleted.emit(path_data)

func create_path(start: FactoryHex, _start_dir: HexVector.Direction, end: FactoryHex, end_dir: HexVector.Direction) -> Array[FlowHex]:
	print("[Paths] Creating path from %s (%s) to %s (%s)" % [
		start.hex_position,
		_start_dir,
		end.hex_position,
		end_dir,
	])

	for path: PathData in paths:
		var start_already_exists := path.start == start and path.start_output_dir == _start_dir
		var end_already_exists := path.end == end and path.end_input_dir == end_dir
		if start_already_exists or end_already_exists:
			print("[Paths] Path creation failed: start output or end input is already in use")
			return []
	var flow_start := start.get_neighbor(_start_dir)
	var flow_end := end.get_neighbor(end_dir)
	if not (flow_start is FlowHex and flow_end is FlowHex):
		print("[Paths] Path creation failed: start or end is not connected to a flow hex")
		return []

	var flow_start_input := HexVector.direction_rotate(_start_dir, 3)
	var flow_end_output := HexVector.direction_rotate(end_dir, 3)
	if not flow_start_input in flow_start.item_flow.inputs:
		print("[Paths] Path creation failed: start flow hex has no matching input")
		return []
	if not flow_end_output in flow_end.item_flow.outputs:
		print("[Paths] Path creation failed: end flow hex has no matching output")
		return []

	var waypoints := _find_shortest_waypoints(
		flow_start,
		flow_end,
	)
	if waypoints.is_empty():
		print("[Paths] Path creation failed: no route found between flow hexes")
		return []
	var path := PathData.new(start, _start_dir, end, end_dir, waypoints)
	paths.append(path)

	var line_waypoints: Array[Hex] = []
	for waypoint: FlowHex in waypoints:
		line_waypoints.append(waypoint)
	line_waypoints.push_front(start)
	line_waypoints.push_back(end)

	var path_line := PathLine.new_instance(line_waypoints)
	PATH_LINE_MAP[path] = path_line
	add_child(path_line)

	path_created.emit(path)
	print("[Paths] Path created with %d waypoints" % waypoints.size())
	return waypoints

func _find_shortest_waypoints(start: FlowHex, end: FlowHex) -> Array[FlowHex]:
	var frontier: Array[FlowHex] = [start]
	var came_from: Dictionary[FlowHex, FlowHex] = {start: null}
	var next_index := 0

	while next_index < frontier.size():
		var current := frontier[next_index]
		next_index += 1

		if current == end:
			return _build_waypoints(came_from, current)

		for neighbor: FlowHex in _flow_neighbors(current):
			if came_from.has(neighbor):
				continue
			came_from[neighbor] = current
			frontier.append(neighbor)
			print(neighbor.hex_position)

	return []

func _flow_neighbors(hex: FlowHex) -> Array[FlowHex]:
	var neighbors: Array[FlowHex] = []
	for direction: HexVector.Direction in hex.item_flow.outputs:
		var position := hex.hex_position.add(HexVector.direction_vector(direction))
		var neighbor: Hex = GameManager.hex_grid.get_hex_at(position)
		if not neighbor is FlowHex:
			continue

		var neighbor_input := HexVector.direction_rotate(direction, 3)
		if neighbor_input in neighbor.item_flow.inputs:
			neighbors.append(neighbor)
	return neighbors

func _build_waypoints(
	came_from: Dictionary[FlowHex, FlowHex],
	end: FlowHex,
) -> Array[FlowHex]:
	var waypoints: Array[FlowHex] = []
	var current: FlowHex = end

	while current != null:
		waypoints.push_front(current)
		current = came_from[current]

	return waypoints

func spawn_item_on_path(item_data: ItemData, path_data: PathData) -> Item:
	print(path_data)
	if not PATH_LINE_MAP.has(path_data):
		push_error("Cannot spawn item: path has no PathLine")
		return null

	var path_line := PATH_LINE_MAP[path_data]
	var path_follow: PathFollow2D = PathFollow2D.new()
	path_line.add_child(path_follow)
	var item := Item.new_instance(item_data, path_follow)
	path_follow.add_child(item)
	return item
