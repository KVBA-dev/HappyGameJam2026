class_name Item
extends Area2D

@export var item_data: ItemData
const SCENE := preload("res://src/item/item.tscn")

static func new_instance() -> Item:
	return SCENE.instantiate()
