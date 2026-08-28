class_name Cards extends Resource

@export var list: Array[CardData]


func pick_random_weighted() -> CardData:
	var grouped := _group_by_rarity()
	var rarity := CardData.random_rarity()

	if grouped[rarity as int].is_empty():
		rarity = CardData.Rarity.COMMON

	return grouped[rarity as int].pick_random()


func _group_by_rarity() -> Array:
	var grouped := []
	for val in CardData.Rarity.values():
		grouped.push_back([])

	for card in list:
		grouped[card.rarity].push_back(card)
	return grouped

func rarity_test():
	var grouped := []
	for val in CardData.Rarity.values():
		grouped.push_back(0)

	for i in range(10000):
		grouped[CardData.random_rarity()] += 1

	print(grouped)
