class_name GameOverScreen
extends CanvasLayer

@onready var reset_button: Button = $Panel/Layout/RetryButton

func _ready() -> void:
	SignalBus.game_timer_timeout.connect(on_game_timer_timeout)
	SignalBus.game_reset.connect(func(): visible = false)
	reset_button.pressed.connect(SignalBus.game_reset.emit)
	visible = false

func on_game_timer_timeout() -> void:
	visible = true
