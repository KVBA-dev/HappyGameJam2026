extends CanvasLayer

@onready var paused_label: Label = $PausedLabel

func _ready() -> void:
	SignalBus.pause_toggled.connect(func(is_paused: bool): 
		paused_label.visible = is_paused
	)
