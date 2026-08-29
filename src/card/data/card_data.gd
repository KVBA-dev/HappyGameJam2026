## TODO: Add data about each card
class_name CardData extends Resource

enum Type {
	PLACABLE = 0,
	USABLE = 1
}

enum Rarity {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
}

static func rarity_percentage(r: Rarity) -> float:
	match r:
		Rarity.COMMON: return 0.50
		Rarity.UNCOMMON: return 0.30
		Rarity.RARE: return 0.20
	return 0.0

static func _get_rarity_sum() -> Array[float]:
	var arr: Array[float] = []
	var sum = 0.0
	for val: Rarity in Rarity.values():
		sum += rarity_percentage(val)
		arr.push_back(sum)
	return arr

static func random_rarity() -> Rarity:
	var arr := _get_rarity_sum()
	var rfloat = randf_range(0.0, arr.back())

	for idx in range(len(arr)):
		if rfloat <= arr[idx]:
			return Rarity.values()[idx]

	return Rarity.values().back()


@export var type: Type
@export var hex_data: HexData

@export var rarity: Rarity = Rarity.COMMON
