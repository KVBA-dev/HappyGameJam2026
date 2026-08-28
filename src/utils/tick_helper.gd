class_name TickHelper extends Node

signal timeout
var timeout_ticks := 100
var _ticks := 0
var ticks: int:
	get: return _ticks

func _init(timeout_ticks_: int) -> void:
	timeout_ticks = timeout_ticks_
	SignalBus.game_timer_tick.connect(_tick)

func fire_next_tick():
	ticks = 0
	

func _tick():
	_ticks -= 1
	if _ticks <= 0:
		timeout.emit()
		_ticks = timeout_ticks
