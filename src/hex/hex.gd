class_name Hex extends Node2D

@onready var hex_sprite: HexSprite = %HexSprite
@onready var item_detection_area: Area2D = %ItemDetectionArea
@onready var mouse_detection_area: Area2D = %MouseDetectionArea
@onready var mouse_detection_shape: CollisionPolygon2D = $Displacement/MouseDetectionArea/CollisionShape2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var displacement: Node2D = %Displacement
@export var hex_data: HexData
var is_mouse_inside: bool = false
var hex_position: HexVector = HexVector.ZERO
		 

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
	const SCENE := preload("uid://c35v72ubhgdk6")
	var new_hex: Hex = SCENE.instantiate()
	new_hex.hex_data = _hex_data
	new_hex.hex_position = _hex_position
	new_hex.position = _hex_position.to_pixel()
	new_hex._appear_style = appear_style
	return new_hex

func _ready():
	z_index = 2*hex_position.r # So we have some space in between to z-order things
	hex_sprite.init(hex_data)
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


func _input(_event: InputEvent) -> void:
	if is_mouse_inside and Input.is_action_just_pressed("select_hex"):
		var polygon_center := Vector2.ZERO
		for point: Vector2 in mouse_detection_shape.polygon:
			polygon_center += point
		polygon_center /= mouse_detection_shape.polygon.size()

		var mouse_position := mouse_detection_shape.to_local(get_global_mouse_position())
		var dir := HexVector.angle_to_dir((mouse_position - polygon_center).angle())
		SignalBus.selected_hex.emit(self, dir)

func _on_mouse_entered():
	is_mouse_inside = true
	var tooltip := TextTooltip.new_instance(str(hex_position))
	GameManager.main.tooltip_canvas.show_tooltip(self, tooltip)
	currently_hovered = self

func _on_mouse_exited():
	is_mouse_inside = false
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
