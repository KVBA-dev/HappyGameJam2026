class_name HexGrid extends Node2D

@onready var root_hex: Hex = %RootHex
var hex_map: Dictionary[HexVector, Hex] = {}
signal hex_changed(hex: Hex)

func _ready():
    GameManager.hex_grid = self
    hex_map[HexVector.ZERO] = root_hex

func get_hex_at(_position: HexVector) -> Hex:
    return hex_map.get(_position, null)

func spawn_hex_at(_position: HexVector, hex_type: HexData) -> Hex:
    if hex_map.has(_position):
        ErrorBus.hex_already_exist_on_position.emit(_position)
        return
    
    var new_hex := Hex.new_instance(_position, hex_type)
    root_hex.add_child(new_hex)
    hex_map[_position] = new_hex
    hex_changed.emit(new_hex)
    return new_hex
