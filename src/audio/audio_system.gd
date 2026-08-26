class_name AudioSystem
extends Node

@onready var music_player: AudioStreamPlayer = $Music
@onready var ambience_player: AudioStreamPlayer = $Ambience
@onready var sfx_player: AudioStreamPlayer = $SFX

static var instance: AudioSystem

enum SFXType {
	HOVER,
	CLICK,
	CANCEL,
	BUILD,
}

@export var sfx_sounds: Dictionary[SFXType, AudioStream]
@export var music_streams: Array[AudioStream]

var music_index: int = 0

func _ready() -> void:
	instance = self
	music_index = 0
	music_player.finished.connect(func(): 
		music_index = (music_index + 1) % len(music_streams)
		load_and_play_music()
	)
	SignalBus.card_used.connect(func(..._a): play_sfx(SFXType.BUILD))
	SignalBus.selected_hex.connect(func(..._a): play_sfx(SFXType.CLICK))
	SignalBus.card_hovered.connect(func(..._a): play_sfx(SFXType.HOVER))
	load_and_play_music()

func load_and_play_music() -> void:
	music_player.stream = music_streams[music_index]
	music_player.play()

func play_sfx(type: SFXType) -> void:
	sfx_player.stream = sfx_sounds[type]
	sfx_player.play()
