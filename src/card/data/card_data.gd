## TODO: Add data about each card
class_name CardData extends Resource

enum Type {
    PLACABLE = 0,
    USABLE = 1
}

@export var type: Type
@export var hex_data: HexData