@warning_ignore_start("unused_signal")
extends Node

# Used when player wants to spawn hex on position where hex already exists.
signal hex_already_exist_on_position(position: HexVector)
signal hex_too_far_from_existing(position: HexVector)
signal hex_misses_valid_path(position: HexVector)
