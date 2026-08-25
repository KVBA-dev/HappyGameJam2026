## TODO: Add data about each hex
class_name HexData extends Resource

enum Type {
    BLANK,
    BLANK_UNPLACABLE,
    FLOW,
    FACTORY
}

func should_surround_by_blanks() -> bool:
    return type != Type.BLANK and type != Type.BLANK_UNPLACABLE

@export var hex_name: String
@export var texture: Texture2D
@export var on_surface_texture: Texture2D
@export var below_texture: Texture2D
@export var type: Type

@export var recipe: Recipe
@export var item_flow: Flow