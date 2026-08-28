## TODO: Add data about each hex
class_name HexData extends Resource

static var river_material: ShaderMaterial = preload("res://assets/shaders/river_material.tres")

enum Type {
	BLANK = 0,
	FLOW = 1,
	FACTORY = 2
}

func should_surround_by_blanks() -> bool:
	return type != Type.BLANK

@export var hex_name: String
@export var texture: Texture2D
@export var on_surface_texture: Texture2D
@export var factory_icon_texture: Texture2D
@export var below_texture: Texture2D
@export var type: Type

@export var recipe: Recipe
@export var item_flow: Flow


func _to_string() -> String:
	return hex_name

func get_production_texture() -> Texture2D:
	return recipe.produces.texture

func get_requirements() -> Array[ItemData]:
	return recipe.requirements.keys()