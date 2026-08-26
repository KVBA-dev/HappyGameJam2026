## TODO: Add data about each card
class_name CardData extends Resource

enum Type {
    PLACABLE,
    USABLE
}

@export var type: Type
@export var hex_data: HexData

var n_60degree_rotations = 0
