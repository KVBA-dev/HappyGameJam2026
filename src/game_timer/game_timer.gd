class_name GameTimer
extends Node

@export var tick_interval: float = 1.0
@export var timeout_interval: float = 60.0

var _curr_tick: float
var _curr_timeout: float
var _timed_out: bool

var remaining_time: float:
	get():
		return _curr_timeout

func _ready() -> void:
	SignalBus.game_reset.connect(reset)
	reset()

func reset() -> void:
	_curr_tick = tick_interval
	_curr_timeout = timeout_interval
	_timed_out = false

func _process(delta: float) -> void:
	if GameManager.main.paused:
		return
	_curr_tick -= delta
	_curr_timeout -= delta
	if _curr_tick <= 0.0:
		_curr_tick += tick_interval
		SignalBus.game_timer_tick.emit()
	if _curr_timeout <= 0.0:
		_curr_timeout = 0.0
		if not _timed_out:
			SignalBus.game_timer_timeout.emit()
			_timed_out = true
