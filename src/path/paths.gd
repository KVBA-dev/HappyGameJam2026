class_name Paths extends RefCounted

var paths: Array[PathData]

func _ready() -> void:
    GameManager.paths = self

func create_path(start: FactoryHex, start_dir: HexVector.Direction, end: FactoryHex, end_dir: HexVector.Direction) -> bool:
    for path: PathData in paths:
        var start_already_exists := path.start == start and path.start_output_dir == start_dir
        var end_already_exists := path.end == end and path.end_input_dir == end_dir
        if start_already_exists or end_already_exists:
            return false

    var flow_start := start.get_neighbor(start_dir)
    var flow_end := end.get_neighbor(end_dir)
    if not (flow_start is FlowHex and flow_end is FlowHex):
        return false
    var waypoints := _find_shortest_waypoints(
        flow_start,
        flow_end,
    )
    if waypoints.is_empty():
        return false

    paths.append(PathData.new(start, start_dir, end, end_dir, waypoints))
    return true

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
    for direction: HexVector.Direction in HexVector.Direction.values():
        var position := hex.hex_position.add(HexVector.direction_vector(direction))
        var neighbor := GameManager.hex_grid.get_hex_at(position)
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
