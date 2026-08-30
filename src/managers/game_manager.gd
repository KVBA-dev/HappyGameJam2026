## It's purpose is to contain only crucial game parts. It should be as short as possible and used as rarely as it's possible.
@warning_ignore_start("unused_signal")
extends Node

var hex_grid: HexGrid
var card_holder: CardHolder
var main: Main
var paths: Paths
var progress_tree: ProgressTree = preload("res://const_data/progress/progress_tree.tres")


const cards: Cards = preload("res://const_data/cards/flow_cards.tres") # cards and infinites should be exclusive
const usable_cards: Cards = preload("res://const_data/cards/usable_cards.tres")
const infinites: Cards = preload("res://const_data/cards/infinite_cards.tres")
