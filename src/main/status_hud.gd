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
	var time := game_timer.remaining_time
	var minutes: int = floor(time / 60.0) as int
	var seconds: int = (floor(time) as int) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	if time < 10:
		var t: float = time - (floor(time) as float)
		timer_label.self_modulate = lerp(Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 0.08, 0.08, 1.0), t)
