class_name TrashCan extends Sprite2D

@onready var bin_area: HoverableArea = %BinArea

func _process(delta: float) -> void:
	var target_scale = Vector2.ONE
	if bin_area.hover:
		target_scale *= 1.1

	const SCALE_SPEED = 10.0
	scale = Vector2(
		Utils.smooth_exp(scale.x, target_scale.x, SCALE_SPEED, delta),
		Utils.smooth_exp(scale.y, target_scale.y, SCALE_SPEED, delta)
	)
