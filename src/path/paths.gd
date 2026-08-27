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
	SignalBus.selected_hex.connect(_on_selected_hex)

func _on_selected_hex(hex: Hex, dir: HexVector.Direction):
	if not hex is FactoryHex:
		return
	if start_hex:
		if not dir in hex.item_flow.inputs:
			return
		var waypoints: Array[Hex] = []
		var created_path := create_path(start_hex, start_dir, hex, dir)
		if created_path.is_empty():
			start_hex = null
			return
		for waypoint: FlowHex in created_path:
			waypoints.append(waypoint)
		waypoints.push_front(start_hex)
		waypoints.push_back(hex)
		var path_line := PathLine.new_instance(waypoints)
		PATH_LINE_MAP[paths.back()] = path_line
		add_child(path_line)
		start_hex = null
	else:
		if not dir in hex.item_flow.outputs:
			return
		start_hex = hex
		start_dir = dir

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
	for path: PathData in paths:
		var start_already_exists := path.start == start and path.start_output_dir == start_dir
		var end_already_exists := path.end == end and path.end_input_dir == end_dir
		if start_already_exists or end_already_exists:
			return []
	var flow_start := start.get_neighbor(_start_dir)
	var flow_end := end.get_neighbor(end_dir)
	if not (flow_start is FlowHex and flow_end is FlowHex):
		return[]
	var waypoints := _find_shortest_waypoints(
		flow_start,
		flow_end,
	)
	if waypoints.is_empty():
		return []
	var path := PathData.new(start, _start_dir, end, end_dir, waypoints)
	paths.append(path)
	path_created.emit(path)
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

	return []

func _flow_neighbors(hex: FlowHex) -> Array[FlowHex]:
	var neighbors: Array[FlowHex] = []
	for direction: HexVector.Direction in hex.item_flow.outputs:
		var position := hex.hex_position.add(HexVector.direction_vector(direction))
		var neighbor: Hex = GameManager.hex_grid.get_hex_at(position)
		if neighbor is FlowHex:
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
	if not PATH_LINE_MAP.has(path_data):
		push_error("Cannot spawn item: path has no PathLine")
		return null

	var path_line := PATH_LINE_MAP[path_data]
	var path_follow: PathFollow2D = PathFollow2D.new()
	path_line.add_child(path_follow)
	var item := Item.new_instance(item_data, path_follow)
	path_follow.add_child(item)
	return item
