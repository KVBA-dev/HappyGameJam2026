class_name GameOverScreen
extends CanvasLayer

@onready var reset_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	SignalBus.game_reset.connect(func(): visible = false)
	SignalBus.game_win.connect(func(): visible = true)
	reset_button.pressed.connect(SignalBus.game_reset.emit)
	quit_button.pressed.connect(get_tree().quit)
	visible = false
