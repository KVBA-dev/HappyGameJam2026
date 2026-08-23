class_name TooltipCanvas extends CanvasLayer

var tooltip: Control

func show_tooltip(_tooltip: Tooltip):
	tooltip = _tooltip
	add_child(_tooltip)
	tooltip.position = _tooltip_pos()

func hide_tooltip():
	if tooltip:
		tooltip.queue_free()

func _process(_delta: float) -> void:
	if tooltip:
		tooltip.global_position = lerp(tooltip.global_position, _tooltip_pos(),0.2)


func _tooltip_pos() -> Vector2:
	return get_viewport().get_mouse_position() + Vector2(8, 8)