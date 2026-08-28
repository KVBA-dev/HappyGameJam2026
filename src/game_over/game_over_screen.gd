class_name GameOverScreen
extends CanvasLayer

@onready var reset_button: Button = $Panel/Layout/RetryButton

func _ready() -> void:
	SignalBus.game_reset.connect(func(): visible = false)
	reset_button.pressed.connect(SignalBus.game_reset.emit)
	visible = false
