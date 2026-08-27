class_name Cards extends Resource

@export var list: Array[CardData]


func pick_random() -> CardData:
    return list.pick_random()