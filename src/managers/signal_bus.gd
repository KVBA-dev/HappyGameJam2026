## Is only purpose is to store signals and allow other scripts to connect to them.
@warning_ignore_start("unused_signal")
extends Node

signal main_loaded

signal game_timer_tick
signal pause_toggled(is_paused: bool)

signal card_used(data: CardHudBase, pos: HexVector)
signal card_used_animation_started(card: CardHudBase)

signal selected_hex(hex: FactoryHex, dir: HexVector.Direction)
signal card_hovered(data: CardData)
signal card_unhovered(data: CardData)

signal path_visibility_toggled(visible: bool)
signal hex_hovered(hex: Hex) # hex can be equal to null
signal hex_selected(hex: Hex)
signal hex_deselected(hex: Hex)
signal hex_factory_clicked(hex: FactoryHex, dir: HexVector.Direction)

signal item_produced(item: ItemData) # emitted every time an item is produced
signal item_achieved(item: ItemData) # emitted when an item is produced for the first time

signal card_binned(card: CardHudBase)
signal card_rotated(card: CardHudBase)
signal card_picked(card: CardHudBase)

signal game_reset

signal factory_connected(factory: FactoryHex)
signal factory_disconnected(factory: FactoryHex)
signal factory_unlocked
signal game_win


signal go_unconnected
