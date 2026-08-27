class_name Hex extends Node2D

@onready var hex_sprite: HexSprite = %HexSprite
@onready var item_detection_area: Area2D = %ItemDetectionArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var displacement: Node2D = %Displacement
@export var hex_data: HexData
var hex_position: HexVector = HexVector.ZERO

# DATA FOR EACH HEX
var item_flow: Flow
var type: HexData.Type
# DATA FOR EACH HEX

enum AppearStyle {
	Below = 0,
	Above = 1,
	Instant = 2
}
var _appear_style: AppearStyle = AppearStyle.Instant

static func new_instance(
		_hex_position: HexVector, 
		_hex_data: HexData,
		appear_style: AppearStyle = AppearStyle.Above) -> Hex:
	const SCENE := preload("uid://c35v72ubhgdk6")
	var new_hex: Hex = SCENE.instantiate()
	new_hex.init_data(_hex_position, _hex_data, appear_style)
	return new_hex

func init_data(
		_hex_position: HexVector, 
		_hex_data: HexData,
		appear_style: AppearStyle) -> void:
	hex_data = _hex_data
	hex_position = _hex_position
	position = _hex_position.to_pixel()
	_appear_style = appear_style

func _ready():
	z_index = 2*hex_position.r # So we have some space in between to z-order things
	hex_sprite.init(hex_data)
	item_flow = hex_data.item_flow.duplicate_deep() if hex_data.item_flow else null
	type = hex_data.type

	item_detection_area.area_entered.connect(on_item_entered)

	match _appear_style:
		AppearStyle.Below:
			visible = false
			animation_player.play("spawn_below")
		AppearStyle.Above:
			displacement.position.y = -40
			animation_player.play("spawn_above")

func distance_to(other: HexData) -> int:
	return hex_position.distance_to(other.hex_position)

func rotate_hex(n_60degree_rotations: int) -> void:
	item_flow.rotate(n_60degree_rotations)
	hex_sprite.insta_rotate(n_60degree_rotations)

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


#func _input(_event: InputEvent) -> void:
#	# TODO: It can fire on two hexes at once, watch out
#	if is_mouse_inside and Input.is_action_just_pressed("select_hex"):
#		var dir := _mouse_dir()
#		SignalBus.hex_factory_clicked.emit(self, dir)
#
#func _mouse_dir() -> HexVector.Direction:
#	var polygon_center := Vector2.ZERO
#	for point: Vector2 in mouse_detection_shape.polygon:
#		polygon_center += point
#	polygon_center /= mouse_detection_shape.polygon.size()
#
#	var mouse_position := mouse_detection_shape.to_local(get_global_mouse_position())
#	return HexVector.angle_to_dir((mouse_position - polygon_center).angle())

# Virtual
func select():
	pass

# Virtual
func deselect():
	pass

func animated_kill():
	item_detection_area.area_entered.disconnect(on_item_entered)

	animation_player.play("disappear")
	animation_player.animation_finished.connect(func(_anim_name):
		queue_free()	
	)

# To be implmented in inherited classes
func on_item_input(_item: Item):
	pass
