class_name PathData extends RefCounted


var start: FactoryHex
var start_output_dir: HexVector.Direction
var end: FactoryHex
var end_input_dir: HexVector.Direction
var waypoints: Array[FlowHex]

func _init(_start: FactoryHex, _start_output_dir: HexVector.Direction, _end: FactoryHex, _end_input_dir: HexVector.Direction, _waypoints: Array[FlowHex]) -> void:
    start = _start
    start_output_dir = _start_output_dir
    end = _end
    end_input_dir = _end_input_dir
    waypoints = _waypoints