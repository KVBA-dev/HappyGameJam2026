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

static var ZERO: HexVector:
	get():
		return HexVector.new(0, 0)

static func direction_rotate(direction: Direction, n_60degree: int) -> Direction:
	var dir_vec := direction_vector(direction)
	dir_vec = dir_vec.rotated(n_60degree)
	return vector_direction(dir_vec)

static func direction_vector(direction: Direction) -> HexVector:
	return DIRECTION_MAP[direction] 

static func vector_direction(vector: HexVector) -> Direction:
	for direction in DIRECTION_MAP:
		if DIRECTION_MAP[direction].comp(vector):
			return direction
	return Direction.UP_RIGHT

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
	return vec == other.vec

func mult(val: int) -> HexVector:
	return HexVector.new(q * val, r * val)

func to_pixel(hex_width: float = Consts.HEX_WIDTH, hex_height: float = Consts.HEX_HEIGHT) -> Vector2:
	var x: float = hex_width * (q + r / 2.0)
	var y: float = hex_height * 0.75 * r
	return Vector2(x, y)

func _to_string() -> String:
	return "HexVector(%d, %d)" % [q, r]
