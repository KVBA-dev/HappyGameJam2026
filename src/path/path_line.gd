class_name PathLine extends Line2D

var waypoints: Array[Hex] = []

func _ready() -> void:
    points = PackedVector2Array(
        waypoints.map(func(hex: Hex) -> Vector2: return hex.hex_position.to_pixel())
    )