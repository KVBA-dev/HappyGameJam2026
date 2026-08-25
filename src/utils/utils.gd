class_name Utils

static func smooth_exp(a: float, b: float, speed: float, delta: float) -> float:
	return lerp(a, b, 1.0 - exp(-speed * delta))
