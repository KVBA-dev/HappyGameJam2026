class_name GameTimer
extends Node

@export var tick_interval: float = 1.0

var _curr_tick: float
var _curr_time: float

var current_time: float:
	get():
		return _curr_time

func _ready() -> void:
	SignalBus.game_reset.connect(reset)
	reset()

func reset() -> void:
	_curr_tick = tick_interval
	_curr_time = 0.0

func _process(delta: float) -> void:
	if GameManager.main.paused:
		return

	_curr_time += delta
	_curr_tick -= delta
	if _curr_tick <= 0.0:
		_curr_tick += tick_interval
		SignalBus.game_timer_tick.emit()
