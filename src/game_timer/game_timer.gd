class_name GameTimer
extends Node

@export var tick_interval: float = 1.0
@export var timeout_interval: float = 60.0

var _curr_tick: float
var _curr_timeout: float
var _time_scale: float
var _timed_out: bool

func _ready() -> void:
	_time_scale = 1.0
	reset(tick_interval, timeout_interval)
	SignalBus.pause_toggled.connect(_on_pause_toggled)

func reset(tick_inter: float, timeout_inter: float) -> void:
	_curr_tick = tick_inter
	_curr_timeout = timeout_inter
	_timed_out = false

func _process(delta: float) -> void:
	_curr_tick -= delta * _time_scale
	_curr_timeout -= delta * _time_scale
	if _curr_tick <= 0.0:
		_curr_tick += tick_interval
		SignalBus.game_timer_tick.emit()
	if _curr_timeout <= 0.0:
		_curr_timeout = 0.0
		if not _timed_out:
			SignalBus.game_timer_timeout.emit()
			_timed_out = true

func _on_pause_toggled(is_paused: bool) -> void:
	_time_scale = 0.0 if is_paused else 1.0
