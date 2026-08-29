class_name CardUsed extends RefCounted

var card: CardData
var pos: HexVector


func _init(_card: CardData, _pos: HexVector) -> void:
    card = _card
    pos = _pos