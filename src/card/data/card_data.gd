## TODO: Add data about each card
class_name CardData extends Resource

enum Type {
    USABLE,
    PLACABLE
}

@export var texture: Texture2D
@export var hex_data: HexData
