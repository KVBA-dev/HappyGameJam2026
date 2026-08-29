class_name TooltipCanvas extends CanvasLayer

var tooltip: Control
var current_owner: Node

func show_tooltip(tooltip_owner: Node, _tooltip: Tooltip):
	current_owner = tooltip_owner
	hide_tooltip(current_owner)
	tooltip = _tooltip
	add_child(_tooltip)
	tooltip.position = _tooltip_pos()

func hide_tooltip(tooltip_owner: Node):
	if not tooltip or tooltip_owner != current_owner:
		return
	tooltip.queue_free()
	tooltip = null

func _process(_delta: float) -> void:
	if tooltip:
		tooltip.global_position = lerp(tooltip.global_position, _tooltip_pos(),0.2)


func _tooltip_pos() -> Vector2:
	return get_viewport().get_mouse_position() + Vector2(8, -24)
