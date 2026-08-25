class_name Hex extends Node2D


@onready var background_sprite: Sprite2D = %BackgroundSprite
@onready var on_hex_sprite: Sprite2D = %OnHexSprite
@onready var item_detection_area: Area2D = %ItemDetectionArea
@onready var mouse_detection_area: Area2D = %MouseDetectionArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var displacement: Node2D = %Displacement
@export var hex_data: HexData
var hex_position: HexVector = HexVector.ZERO
const SCENE := preload("uid://c35v72ubhgdk6")

static var currently_hovered: Hex

enum AppearStyle {
	Below,
	Above,
	Instant
}
var _appear_style: AppearStyle = AppearStyle.Instant

static func new_instance(
		_hex_position: HexVector, 
		_hex_data: HexData, 
		appear_style: AppearStyle = AppearStyle.Above) -> Hex:
	var new_hex: Hex = SCENE.instantiate()
	new_hex.hex_data = _hex_data
	new_hex.hex_position = _hex_position
	new_hex.position = _hex_position.to_pixel()
	new_hex._appear_style = appear_style
	return new_hex

func _ready():
	z_index = 2*hex_position.r # So we have some space in between to z-order things
	background_sprite.texture = hex_data.texture
	on_hex_sprite.texture = hex_data.on_surface_texture
	item_detection_area.area_entered.connect(on_item_entered)
	mouse_detection_area.mouse_entered.connect(_on_mouse_entered)
	mouse_detection_area.mouse_exited.connect(_on_mouse_exited)

	match _appear_style:
		AppearStyle.Below:
			visible = false
			animation_player.play("spawn_below")
		AppearStyle.Above:
			displacement.position.y = -40
			animation_player.play("spawn_above")


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
	if area is Item:
		on_item_input(area)


func _on_mouse_entered():
	var tooltip := TextTooltip.new_instance(str(hex_position))
	GameManager.main.tooltip_canvas.show_tooltip(self, tooltip)
	currently_hovered = self

func _on_mouse_exited():
	GameManager.main.tooltip_canvas.hide_tooltip(self)
	if currently_hovered == self:
		currently_hovered = null

func animated_kill():
	item_detection_area.area_entered.disconnect(on_item_entered)
	mouse_detection_area.mouse_entered.disconnect(_on_mouse_entered)
	mouse_detection_area.mouse_exited.disconnect(_on_mouse_exited)

	animation_player.play("disappear")
	animation_player.animation_finished.connect(func(_anim_name):
		queue_free()	
	)

# To be implmented in inherited classes
func on_item_input(_item: Item):
	pass
