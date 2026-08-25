class_name HexVector extends RefCounted


var vec: Vector2i
var q: int:
	get:
		return vec.x
	set(val):
		vec.x = val
var r: int:
	get:
		return vec.y
	set(val):
		vec.y = val

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

static var vectors: Array[HexVector] = []
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


static func angle_to_dir(angle: float) -> Direction:
	var normalized_angle := fposmod(angle, TAU)
	var sector := int(floor((normalized_angle + PI / 6.0) / (PI / 3.0))) % 6
	match sector:
		0:
			return Direction.CENTER_RIGHT
		1:
			return Direction.DOWN_RIGHT
		2:
			return Direction.DOWN_LEFT
		3:
			return Direction.CENTER_LEFT
		4:
			return Direction.UP_LEFT
		5:
			return Direction.UP_RIGHT
	return Direction.CENTER_RIGHT


static var ZERO: HexVector:
	get():
		return HexVector.new(0, 0)

static func direction_vector(direction: Direction) -> HexVector:
	return DIRECTION_MAP[direction] 

func neighbor(direction: Direction) -> HexVector:
	var d := direction_vector(direction)
	return HexVector.new(q + int(d.q), r + int(d.r))

func get_all_neighbors() -> Array[HexVector]:
	var result: Array[HexVector] = []
	for direction in Direction.values():
		result.append(neighbor(direction))
	return result

func _init(_q: int, _r: int):
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
		0: return HexVector.new_instance(q, r)
		1: return HexVector.new_instance(-r, -s())
		2: return HexVector.new_instance(-q-r, q)
		3: return HexVector.new_instance(-q, -r)
		4: return HexVector.new_instance(r, -q-r)
		5: return HexVector.new_instance(q+r, -q)
	return null	

func add(other: HexVector) -> HexVector:
	return HexVector.new(q + other.q, r + other.r)

func sub(other: HexVector) -> HexVector:
	return HexVector.new(q - other.q, r - other.r)

func comp(other: HexVector) -> bool:
	return vec == other.vec

func mult(val: int) -> HexVector:
	return HexVector.new_instance(q * val, r * val)

func to_pixel(hex_width: float = Consts.HEX_WIDTH, hex_height: float = Consts.HEX_HEIGHT) -> Vector2:
	var x: float = hex_width * (q + r / 2.0)
	var y: float = hex_height * 0.75 * r
	return Vector2(x, y)

func _to_string() -> String:
	return "HexVector(%d, %d)" % [q, r]
