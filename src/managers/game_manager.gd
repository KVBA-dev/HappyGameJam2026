## It's purpose is to contain only crucial game parts. It should be as short as possible and used as rarely as it's possible.
@warning_ignore_start("unused_signal")
extends Node

var scenes: Scenes = preload("res://const_data/scenes/scenes.tres")
signal scenes_set(value: Scenes)
