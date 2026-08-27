## Is only purpose is to store signals and allow other scripts to connect to them.
@warning_ignore_start("unused_signal")
extends Node

signal main_loaded

signal game_timer_tick
signal game_timer_timeout
signal pause_toggled(is_paused: bool)

signal card_used(data: CardData, pos: HexVector)
signal card_used_animation_started(card: CardHudBase)

signal selected_hex(hex: FactoryHex, dir: HexVector.Direction)
signal card_hovered(data: CardData)

signal path_visibility_toggled(visible: bool)
signal hex_hovered(hex: Hex) # hex can be equal to null
signal hex_selected(hex: Hex)
signal hex_deselected(hex: Hex)
signal hex_factory_clicked(hex: FactoryHex, dir: HexVector.Direction)

signal item_produced(item: ItemData)

signal game_reset

signal factory_connected(factory: FactoryHex)