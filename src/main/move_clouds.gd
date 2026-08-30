extends Parallax2D

@export var starting_x: float
@export var ending_x: float
@export var scroll_speed: float = 1.0
var clouds: Array[Sprite2D]

func _ready() -> void:
	for child: Node in get_children():
		if child is Sprite2D:
			clouds.append(child as Sprite2D)

func _process(delta: float) -> void:
	for cloud: Sprite2D in clouds:
		cloud.position.x += delta * scroll_speed
		if cloud.position.x >= ending_x:
			var tween := get_tree().create_tween()
			tween.tween_property(cloud, "modulate", Color(1, 1, 1, 0), 1.0)
			tween.parallel().tween_property(cloud, "position:x", starting_x, 0.0).set_delay(1.0)
			tween.tween_property(cloud, "modulate", Color.WHITE, 1.0)

func _tween_proc(cloud: Sprite2D, t: float):
	cloud.self_modulate.a = abs(t - 1.0)
