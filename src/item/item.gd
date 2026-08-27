class_name Item
extends Area2D

var item_data: ItemData
var path_follow: PathFollow2D
const SCENE := preload("res://src/item/item.tscn")

static func new_instance(_item_data: ItemData, _path_follow: PathFollow2D) -> Item:
	var item: Item = SCENE.instantiate()
	item.item_data = _item_data
	item.path_follow = _path_follow
	item.set_texture(_item_data.texture)
	return item

func _process(delta: float) -> void:
	if GameManager.main.paused:
		return
	path_follow.progress += delta * 100

func get_consumed():
	path_follow.queue_free()
	print("got consumed")

func set_texture(tex: Texture2D) -> void:
	($Sprite2D as Sprite2D).texture = tex
