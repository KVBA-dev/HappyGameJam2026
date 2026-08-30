class_name Stats extends RefCounted

var cards_used: Array[CardUsed] = []


func add_card(card: CardData, pos: HexVector):
    cards_used.append(CardUsed.new(card, pos))