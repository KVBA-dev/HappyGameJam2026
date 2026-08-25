class_name HexVector extends RefCounted

var q: int
var r: int

const HEX_WIDTH := 210.0
const HEX_HEIGHT := 182.0

func s() -> int:
	return -q - r

enum Direction {
	UP_RIGHT,
	UP_LEFT,
	CENTER_RIGHT,
	CENTER_LEFT,
	DOWN_RIGHT,
	DOWN_LEFT
}
static var DIRECTION_MAP: Dictionary[Direction, HexVector] = {
	Direction.UP_RIGHT: HexVector.new_instance(1, -1),
	Direction.UP_LEFT: HexVector.new_instance(-1, 0),
	Direction.CENTER_RIGHT: HexVector.new_instance(1, 0),
	Direction.CENTER_LEFT: HexVector.new_instance(-1, 1),
	Direction.DOWN_RIGHT: HexVector.new_instance(0, 1),
	Direction.DOWN_LEFT: HexVector.new_instance(0, -1)
}

static var vectors: Array[HexVector] = []

static var ZERO: HexVector:
	get():
		return HexVector.new_instance(0, 0)

static func direction_vector(direction: Direction) -> HexVector:
	return DIRECTION_MAP[direction] 

func neighbor(direction: Direction) -> HexVector:
	var d := direction_vector(direction)
	return HexVector.new_instance(q + int(d.x), r + int(d.y))

func get_all_neighbors() -> Array[HexVector]:
	var result: Array[HexVector] = []
	for direction in Direction.values():
		result.append(neighbor(direction))
	return result

static func new_instance(q: int, r: int) -> HexVector:
	var vector: HexVector
	for v: HexVector in vectors:
		if v.q == q and v.r == r:
			vector = v
			break
	if vector:
		return vector
	vector = HexVector.new(q, r)
	vectors.append(vector)
	return vector


func _init(_q: int, _r: int):
	q = _q
	r = _r

func distance_to(other: HexVector) -> int:
	var dq: int = abs(q - other.q)
	var dr: int = abs(r - other.r)
	var ds: int = abs(s() - other.s())
	return (dq + dr + ds) / 2

func add(other: HexVector) -> HexVector:
	return HexVector.new_instance(q + other.q, r + other.r)

func sub(other: HexVector) -> HexVector:
	return HexVector.new_instance(q - other.q, r - other.r)

func to_pixel(hex_width: float = HEX_WIDTH, hex_height: float = HEX_HEIGHT) -> Vector2:
	var x: float = hex_width * (q + r / 2.0)
	var y: float = hex_height * 0.75 * r
	return Vector2(x, y)

func _to_string() -> String:
	return "HexVector(%d, %d)" % [q, r]
