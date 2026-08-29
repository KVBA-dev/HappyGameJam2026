class_name GameOverScreen
extends CanvasLayer

@onready var reset_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton

@onready var particles1: CPUParticles2D = %Particles1
@onready var particles2: CPUParticles2D = %Particles2

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
