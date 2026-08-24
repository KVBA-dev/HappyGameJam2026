class_name CardHudHighlight extends Sprite2D

enum State {
	IN_HAND,
	PREVIEWED,
	DRAGGED
}

@onready var card_holder: CardHolder = get_tree().get_first_node_in_group("card_holder")
var state: State = State.IN_HAND
var _hover: bool = false
var hover: bool:
	get:
		return _hover

func _process(_delta: float) -> void:
	match state:
		State.IN_HAND: _in_hand_processed()
		State.DRAGGED: pass
		State.PREVIEWED: _previewed_process()

func _in_hand_processed():
	scale = Vector2.ONE
	pass

func _previewed_process():
	scale = Vector2.ONE * 1.2
	pass
func _on_area_2d_mouse_entered() -> void:
	_hover = true

func _on_area_2d_mouse_exited() -> void:
	_hover = false

