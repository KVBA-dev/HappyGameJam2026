## TODO: Add data about each card
class_name CardData extends Resource

enum Type {
    USABLE,
    PLACABLE
}

@export var card_type: Type
@export var hex_data: HexData
