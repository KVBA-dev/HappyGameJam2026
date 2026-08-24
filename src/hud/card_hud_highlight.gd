class_name CardHudHighlight extends Sprite2D

enum State {
	IN_HAND,
	PREVIEWED,
	DRAGGED
}

@onready var card_holder: CardHolder = get_tree().get_first_node_in_group("card_holder")
var _state: State = State.IN_HAND
var state: State:
	get:
		return _state
	set(value):
		_state = value
		_on_state_change()

var _hover: bool = false
var hover: bool:
	get:
		return _hover

func _process(_delta: float) -> void:
	match _state:
		State.IN_HAND: _in_hand_processed()
		State.DRAGGED: pass
		State.PREVIEWED: _previewed_process()

func _in_hand_processed():
	pass

func _previewed_process():
	pass

func _on_area_2d_mouse_entered() -> void:
	_hover = true

func _on_area_2d_mouse_exited() -> void:
	_hover = false

func _on_state_change():
	match _state:
		State.IN_HAND: 
			scale = Vector2.ONE 
			z_index = 0
		State.PREVIEWED:
			scale = Vector2.ONE * 1.2
			rotation = 0
			z_index = 10
		State.DRAGGED: pass
