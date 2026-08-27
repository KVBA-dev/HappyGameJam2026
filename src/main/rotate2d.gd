extends Sprite2D

@export var rotation_speed: float = 0.1

func _process(delta: float) -> void:
	rotation += delta * rotation_speed
