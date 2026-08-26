## Is only purpose is to store signals and allow other scripts to connect to them.
@warning_ignore_start("unused_signal")
extends Node

signal main_loaded

signal game_timer_tick
signal game_timer_timeout
signal pause_toggled(is_paused: bool)

signal card_used(data: CardHudBase, pos: HexVector)
signal selected_hex(hex: FactoryHex, dir: HexVector.Direction)
