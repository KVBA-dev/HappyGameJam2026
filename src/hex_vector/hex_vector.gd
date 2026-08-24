class_name HexVector extends RefCounted

var q: int
var r: int

const HEX_WIDTH := 122.0
const HEX_HEIGHT := 140.0

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
	Direction.UP_RIGHT: HexVector.new(1, -1),
	Direction.DOWN_LEFT: HexVector.new(-1, 1),

	Direction.CENTER_RIGHT: HexVector.new(1, 0),
	Direction.CENTER_LEFT: HexVector.new(-1, 0),

	Direction.UP_LEFT: HexVector.new(0, -1),
	Direction.DOWN_RIGHT: HexVector.new(0, 1),
}

static func UP_RIGHT() -> HexVector: return direction_vector(Direction.UP_RIGHT)
static func UP_LEFT() -> HexVector: return direction_vector(Direction.UP_LEFT)
static func CENTER_RIGHT() -> HexVector: return direction_vector(Direction.CENTER_RIGHT)
static func CENTER_LEFT() -> HexVector: return direction_vector(Direction.CENTER_LEFT)
static func DOWN_RIGHT() -> HexVector: return direction_vector(Direction.DOWN_RIGHT)
static func DOWN_LEFT() -> HexVector: return direction_vector(Direction.DOWN_LEFT)

static var ZERO: HexVector:
	get():
		return HexVector.new(0, 0)

static func direction_vector(direction: Direction) -> HexVector:
	return DIRECTION_MAP[direction] 

func neighbor(direction: Direction) -> HexVector:
	var d := direction_vector(direction)
	return HexVector.new(q + int(d.x), r + int(d.y))

func get_all_neighbors() -> Array[HexVector]:
	var result: Array[HexVector] = []
	for direction in Direction.values():
		result.append(neighbor(direction))
	return result

func _init(_q: int, _r: int) -> void:
	q = _q
	r = _r

func distance_to(other: HexVector) -> int:
	var dq: int = abs(q - other.q)
	var dr: int = abs(r - other.r)
	var ds: int = abs(s() - other.s())
	return (dq + dr + ds) / 2

func rotated(n: int) -> HexVector:
	n = posmod(n, 6)
	match n:
		0: return HexVector.new(q, r)
		1: return HexVector.new(-r, -s())
		2: return HexVector.new(-q-r, q)
		3: return HexVector.new(-q, -r)
		4: return HexVector.new(r, -q-r)
		5: return HexVector.new(q+r, -q)
	return null	

func add(other: HexVector) -> HexVector:
	return HexVector.new(q + other.q, r + other.r)

func sub(other: HexVector) -> HexVector:
	return HexVector.new(q - other.q, r - other.r)

func comp(other: HexVector) -> bool:
	return q == other.q and r == other.r

func mult(val: int) -> HexVector:
	return HexVector.new(q * val, r * val)

func to_pixel(hex_width: float = HEX_WIDTH, hex_height: float = HEX_HEIGHT) -> Vector2:
	var x: float = hex_width * (q + r / 2.0)
	var y: float = hex_height * 0.75 * r
	return Vector2(x, y)

func _to_string() -> String:
	return "HexVector(%d, %d)" % [q, r]
