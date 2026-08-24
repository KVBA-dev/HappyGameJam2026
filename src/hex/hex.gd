class_name Hex extends Node2D


@onready var on_hex_sprite: Sprite2D = %OnHexSprite
@onready var item_detection_area: Area2D = %ItemDetectionArea
@onready var mouse_detection_area: Area2D = %MouseDetectionArea
@export var hex_data: HexData
var hex_position: HexVector = HexVector.ZERO
const SCENE := preload("uid://c35v72ubhgdk6")


static func new_instance(_hex_position: HexVector, _hex_data: HexData) -> Hex:
	var new_hex: Hex = SCENE.instantiate()
	new_hex.hex_data = _hex_data
	new_hex.hex_position = _hex_position
	new_hex.position = _hex_position.to_pixel()
	return new_hex

func _ready():
	z_index = hex_position.s()
	on_hex_sprite.texture = hex_data.texture
	item_detection_area.area_entered.connect(on_item_entered)
	mouse_detection_area.mouse_entered.connect(_on_mouse_entered)
	mouse_detection_area.mouse_exited.connect(_on_mouse_exited)


func distance_to(other: HexData) -> int:
	return hex_position.distance_to(other.hex_position)

func get_neighbor(direction: HexVector.Direction) -> Hex:
	return GameManager.hex_grid.get_hex_at(hex_position.add(HexVector.direction_vector(direction)))

func get_neighbors() -> Array[Hex]:
	var neighbors: Dictionary[HexVector.Direction, Hex] = {}
	for direction in HexVector.Direction.values():
		neighbors[direction] = get_neighbor(direction)
	return neighbors.values().filter(func(neighbor): return neighbor != null)

func on_item_entered(area: Area2D) -> void:
	on_item_input(area.get_parent())


func _on_mouse_entered():
	var tooltip := TextTooltip.new_instance(str(hex_position))
	GameManager.main.tooltip_canvas.show_tooltip(self, tooltip)

func _on_mouse_exited():
	GameManager.main.tooltip_canvas.hide_tooltip(self)

# TODO: Type item class!
func on_item_input(item):
	pass
