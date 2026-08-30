class_name GameOverScreen
extends CanvasLayer

@onready var reset_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton

@onready var particles1: CPUParticles2D = %Particles1
@onready var particles2: CPUParticles2D = %Particles2

@onready var played_cards: Label = %PlayedCards
@onready var play_time: Label = %PlayTime
@onready var total_hexes: Label = %TotalHexes

func _ready() -> void:
	SignalBus.game_reset.connect(func(): visible = false)
	SignalBus.game_win.connect(show_screen)
	reset_button.pressed.connect(SignalBus.game_reset.emit)
	quit_button.pressed.connect(get_tree().quit)
	visible = false

func show_screen(): 
	visible = true
	particles1.emitting = true
	particles2.emitting = true
	var time: float = GameTimer.instance.current_time
	var play_time_mins: int = floor(time / 60) as int
	var play_time_secs: int = (floor(time) as int) % 60
	play_time.text = "%02d:%02d" % [play_time_mins, play_time_secs]
	played_cards.text = str(len(GameManager.main.stats.cards_used))
	total_hexes.text = str(len(GameManager.hex_grid.blank_hexes))
