class_name Utils

static func smooth_exp(a: float, b: float, speed: float, delta: float) -> float:
	return lerp(a, b, 1.0 - exp(-speed * delta))

static func get_mouse_world_pos(node: Node2D):
	var screen_pos = node.get_global_mouse_position()
	return node.get_viewport().get_canvas_transform().affine_inverse() * screen_pos
