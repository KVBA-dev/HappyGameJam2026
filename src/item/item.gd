class_name Item
extends Area2D

@onready var sprite: Sprite2D = $ItemSprite

var item_data: ItemData
var path_follow: PathFollow2D
const SCENE := preload("res://src/item/item.tscn")
var time_delta: float = randf_range(0, 2)

static func new_instance(_item_data: ItemData, _path_follow: PathFollow2D) -> Item:
	var item: Item = SCENE.instantiate()
	item.item_data = _item_data
	item.path_follow = _path_follow
	return item

func _ready() -> void:
	sprite.texture = item_data.texture

func _process(delta: float) -> void:
	if GameManager.main.paused:
		return
	path_follow.progress += delta * 100
	time_delta += delta
	sprite.position = Vector2(0, sin(time_delta * 5) * 5)
	sprite.global_rotation = sin(time_delta * 5) * 0.1

func get_consumed():
	path_follow.queue_free()
