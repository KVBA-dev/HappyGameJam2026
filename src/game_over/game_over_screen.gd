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
	SignalBus.game_win.connect(func(): 
		visible = true
		particles1.emitting = true
		particles2.emitting = true
	)
	reset_button.pressed.connect(SignalBus.game_reset.emit)
	quit_button.pressed.connect(get_tree().quit)
	visible = false

func _process(delta: float) -> void:
	played_cards.text = str(len(GameManager.main.stats.cards_used))
	# play_time.text = GameManager.main. # TODO: Make show time
	total_hexes.text = str(len(GameManager.hex_grid.hex_map))