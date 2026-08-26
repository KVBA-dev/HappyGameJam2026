extends CanvasLayer

@onready var paused_label: Label = $PausedLabel
@onready var timer_label: Label = $TimerLabel

@export var game_timer: GameTimer

func _ready() -> void:
	SignalBus.pause_toggled.connect(func(is_paused: bool): 
		paused_label.visible = is_paused
	)

func _process(_delta: float) -> void:
	var time := game_timer.remaining_time
	var minutes: int = floor(time / 60.0) as int
	var seconds: int = (floor(time) as int) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
