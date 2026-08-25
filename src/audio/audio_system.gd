class_name AudioSystem
extends Node

@onready var music_player: AudioStreamPlayer = $Music
@onready var sfx_player: AudioStreamPlayer = $SFX

enum SFXType {
	HOVER,
	CLICK,
	CANCEL,
	BUILD,
}

@export var sfx_sounds: Dictionary[SFXType, AudioStream]
@export var music_streams: Array[AudioStream]
