extends CanvasLayer

@onready var paused_label: Label = $PausedLabel
@onready var timer_label: Label = $TimerLabel
@onready var hide_paths_btn: Button = $HidePathsBtn

@export var game_timer: GameTimer

func _ready() -> void:
	SignalBus.pause_toggled.connect(func(is_paused: bool): 
		paused_label.visible = is_paused
	)
	hide_paths_btn.pressed.connect(func():
		GameManager.main.paths_visible = not GameManager.main.paths_visible
		SignalBus.path_visibility_toggled.emit(GameManager.main.paths_visible)
		if GameManager.main.paths_visible:
			hide_paths_btn.text = "Hide paths"
		else:
			hide_paths_btn.text = "Show paths"
	)

func _process(_delta: float) -> void:
	var time := game_timer.current_time
	var minutes: int = floor(time / 60.0) as int
	var seconds: int = (floor(time) as int) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
