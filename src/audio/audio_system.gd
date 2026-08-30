class_name AudioSystem
extends Node

@onready var music_player: AudioStreamPlayer = %Music
@onready var ambience_player: AudioStreamPlayer = %Ambience
@onready var win_player: AudioStreamPlayer = %Win

static var instance: AudioSystem

var wind_volume: float = 0.0

enum SFXType {
	HOVER,
	CLICK,
	CANCEL,
	BUILD,
	ROTATE,
	REMOVE,
	WIN,
	UNLOCK,
	CARD,
}

@export var sfx_sounds: Dictionary[SFXType, AudioStream]
@export var music_streams: Array[AudioStream]

var sfx_streams: Array[AudioStreamPlayer]
var music_index: int = 0
var sfx_index: int = 0

var unlock_timeout: float = 1.0

func _ready() -> void:
	instance = self
	sfx_index = 0
	for i in range(10):
		var stream := AudioStreamPlayer.new()
		stream.volume_db = -3.0
		add_child(stream)
		sfx_streams.append(stream)
	music_index = 0
	music_player.finished.connect(func(): 
		music_index = (music_index + 1) % len(music_streams)
		load_and_play_music()
	)
	SignalBus.card_used.connect(func(..._a): play_sfx(SFXType.BUILD))
	SignalBus.hex_factory_clicked.connect(func(..._a): play_sfx(SFXType.CLICK))
	SignalBus.card_hovered.connect(func(..._a): play_sfx(SFXType.HOVER))
	SignalBus.card_binned.connect(func(..._a): play_sfx(SFXType.REMOVE))
	SignalBus.card_rotated.connect(func(..._a): play_sfx(SFXType.ROTATE))
	GameManager.card_holder.card_dragged.connect(func(..._a): play_sfx(SFXType.CARD))
	SignalBus.game_win.connect(func(): play_sfx(SFXType.WIN))
	SignalBus.factory_unlocked.connect(func(..._a): play_sfx(SFXType.UNLOCK))
	load_and_play_music()

func load_and_play_music() -> void:
	music_player.stream = music_streams[music_index]
	music_player.play()

func play_sfx(type: SFXType) -> void:
	if type == SFXType.WIN:
		win_player.play()
		return
	var sfx_player := sfx_streams[sfx_index]
	sfx_index = (sfx_index + 1) % len(sfx_streams)
	sfx_player.stream = sfx_sounds[type]
	sfx_player.play()

func _process(delta: float) -> void:
	ambience_player.volume_linear = pow(clamp(abs(wind_volume), 0.0, 1.0), 0.5)
	unlock_timeout -= delta
	if unlock_timeout < 0.0:
		unlock_timeout = 0.0
