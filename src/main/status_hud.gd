extends CanvasLayer

@onready var game_pause_container: Container = %GamePauseContainer
@onready var timer_label: Label = %TimerLabel
@onready var cards_on_hand: Label = %CardsOnHandLabel
@onready var hide_paths_btn: Button = %HidePathsBtn
@onready var played_cards_label: Label = %PlayedCardsLabel
@onready var total_hexes_label: Label = %TotalHexesLabel
@onready var go_unconnected_factory_label: Button = %GoToUnconnectedFactoryButton

@export var game_timer: GameTimer

func _ready() -> void:
	SignalBus.pause_toggled.connect(func(is_paused: bool): 
		game_pause_container.visible = is_paused
	)
	hide_paths_btn.pressed.connect(func():
		GameManager.main.paths_visible = not GameManager.main.paths_visible
		SignalBus.path_visibility_toggled.emit(GameManager.main.paths_visible)
		if GameManager.main.paths_visible:
			hide_paths_btn.text = "Hide paths"
		else:
			hide_paths_btn.text = "Show paths"
	)
	go_unconnected_factory_label.pressed.connect(func():
		SignalBus.go_unconnected.emit()
	)

func _process(_delta: float) -> void:
	var time := game_timer.current_time
	var minutes: int = floor(time / 60.0) as int
	var seconds: int = (floor(time) as int) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	cards_on_hand.text =  str(len(GameManager.card_holder.cards) - 1) + "/5"
	if GameManager.main.stats:
		played_cards_label.text = str(len(GameManager.main.stats.cards_used))
	total_hexes_label.text = str(len(GameManager.hex_grid.blank_hexes))
