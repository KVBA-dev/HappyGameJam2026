class_name NeededIcon extends TextureRect

var item_data: ItemData

static func new_instance(_item_data: ItemData) -> NeededIcon:
	const SCENE := preload("res://src/hud/needed_icon.tscn")
	var icon: NeededIcon = SCENE.instantiate()
	icon.item_data = _item_data
	return icon

func _ready() -> void:
	texture = item_data.texture
