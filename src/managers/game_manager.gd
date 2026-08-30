## It's purpose is to contain only crucial game parts. It should be as short as possible and used as rarely as it's possible.
@warning_ignore_start("unused_signal")
extends Node

var hex_grid
var card_holder
var main
var paths
var progress_tree

var cards
var usable_cards
var infinites

func _ready() -> void:
	progress_tree = load("res://const_data/progress/progress_tree.tres")
	cards = load("res://const_data/cards/flow_cards.tres")
	usable_cards = load("res://const_data/cards/usable_cards.tres")
	infinites = load("res://const_data/cards/infinite_cards.tres")
