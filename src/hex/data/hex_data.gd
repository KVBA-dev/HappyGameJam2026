## TODO: Add data about each hex
class_name HexData extends Resource

enum Type {
    BLANK,
    ROAD,
    FACTORY
}

@export var hex_name: String
@export var texture: Texture2D
@export var type: Type

# TODO: Add Recipe Info
@export var item_flow: Flow
