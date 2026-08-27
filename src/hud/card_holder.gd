class_name CardHolder extends Control

const State = CardHudBase.State 


@onready var cards_container: Node2D = %CardsContainer
@onready var placer_center: Node2D = %PlacerCenter
@onready var card_lay_area: HoverableArea = %CardLayArea

var _card_num_limit: int = 5

var currently_focused: CardHudBase = null
var cards: Array[CardHudBase] = []
var can_be_laid_down: bool = true

# signal card_destroyed(card: CardHudBase)
signal card_returned_to_hand(card: CardHudBase)
signal card_dragged(card: CardHudBase)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("card_select") and _can_use_card():
		var card := take_currently_dragged()
		card.start_use_animation()

func _can_use_card() -> bool:
	if not _is_currently(State.DRAGGED) or card_lay_area.hover:
		return false

	match currently_focused.card_data.type:
		CardData.Type.PLACABLE: return _can_use_placable()
		CardData.Type.USABLE: return _can_use_usable()
		_: return false

func _can_use_placable() -> bool:
	var hovered = Cursor.hover_hex
	if not hovered:
		return false

	if hovered.hex_data.type != HexData.Type.BLANK:
		ErrorBus.hex_already_exist_on_position.emit(hovered)
		return false

	var can_place = GameManager.hex_grid.can_place_card(hovered.hex_position)
	if not can_place:
		ErrorBus.hex_too_far_from_existing.emit(hovered)
	return can_place

func _can_use_usable() -> bool:
	# TODO: Implement usable cards
	return false

func is_interacted_with() -> bool:
	if currently_focused == null:
		return false

	return currently_focused.state != State.IN_HAND

func take_currently_dragged() -> CardHudBase:
	var card = currently_focused
	currently_focused.state = State.PLACED
	currently_focused = null
	return card

func add_card(card_data: CardData) -> bool:
	if len(cards) + 1 > _card_num_limit:
		return false

	var visual_scene: CardHudBase = preload("res://src/hud/hud_cards/card_hud_placable.tscn").instantiate()
	cards_container.add_child(visual_scene)
	visual_scene.hex_sprite.init(card_data.hex_data)
	visual_scene.card_data = card_data

	cards.push_front(visual_scene)
	return true

func _ready():
	GameManager.card_holder = self
	for child in cards_container.get_children():
		child.free()

	_test_init()
	reorder_cards()

func _test_init():
	for i in range(5):
		var card_data: CardData = GameManager.cards.pick_random()
		add_card(card_data)

func _process(_delta: float) -> void:
	if not _is_currently(State.DRAGGED):
		var closest := find_closest_hovered()
		_set_currently_focused(closest)
	else:
		reorder_cards()

	_input_handle_rotations()
	_input_handle_card_laydown()
	_input_handle_card_pickup()

func _input_handle_rotations():
	if _is_currently(State.DRAGGED) and not currently_focused.hex_sprite._is_rotating:
		if Input.is_action_pressed("card_rotate_left"):
			currently_focused.rotate_left()
		if Input.is_action_pressed("card_rotate_right"):
			currently_focused.rotate_right()

func _input_handle_card_laydown():
	if (Input.is_action_just_pressed("card_select") \
		or (Input.is_action_just_released("card_select") and can_be_laid_down)) \
		and _is_currently(State.DRAGGED):
		if card_lay_area.hover:
			var idx = find_first_rightside_card_idx(get_global_mouse_position())
			cards.insert(idx, currently_focused)
			card_returned_to_hand.emit(currently_focused)
			currently_focused = null
			reorder_cards()

func _input_handle_card_pickup():
	if Input.is_action_just_pressed("card_select") and _is_currently(State.PREVIEWED):
		currently_focused.state = CardHudBase.State.DRAGGED
		card_dragged.emit(currently_focused)		

		cards.erase(currently_focused)
		reorder_cards()

		can_be_laid_down = false
		get_tree().create_timer(0.1).timeout.connect(func(): can_be_laid_down = true)

func _set_currently_focused(node: CardHudBase):
	if currently_focused:
		currently_focused.state = CardHudBase.State.IN_HAND

	if node:
		node.state = State.PREVIEWED
		if node != currently_focused: 
			SignalBus.card_hovered.emit(node.card_data)

	currently_focused = node
	reorder_cards()

func find_closest_hovered() -> CardHudBase:
	var closest: CardHudBase = null
	var best_distance: float = INF
	for card: CardHudBase in cards:
		if card.hover == false:
			continue

		var distance: float = card.global_position.distance_to(get_global_mouse_position())
		if distance < best_distance:
			closest = card
			best_distance = distance
	return closest	

func find_first_rightside_card_idx(pos: Vector2) -> int:
	var first_card_right_idx: int = len(cards)
	for idx in range(len(cards)):
		if cards[idx].global_position.x > pos.x:
			return idx

	return first_card_right_idx

func reorder_cards() -> void:
	var cards_position_data := get_position_data_for_cards()

	var left_spread = 0.0
	var right_spread = 0.0
	var first_card_right_idx: int = -1
	if _is_currently(State.DRAGGED):
		for idx in range(len(cards)):
			var card_global_calc = cards[idx].get_parent().to_global(cards_position_data[idx].position)
			var distance_to_dragged = currently_focused.global_position.distance_to(card_global_calc)
			var weight = clamp(distance_to_dragged / 200.0, 0.0, 1.0)

			var local_spread_distance = (1.0 - weight) * 0.1
			if cards[idx].global_position.x > currently_focused.global_position.x:
				right_spread = local_spread_distance
				first_card_right_idx = idx
				break

			left_spread = -local_spread_distance
			
	for idx in range(len(cards)):
		var movement_angle = cards_position_data[idx].rotation
		if first_card_right_idx > 0:
			movement_angle += left_spread if idx < first_card_right_idx else right_spread

		cards[idx].target_pos = _calculate_card_position(movement_angle)
		if cards[idx].state == State.IN_HAND:
			cards[idx].z_index = cards[idx].MIN_Z_INDEX + idx
			cards[idx].rotation = cards_position_data[idx].rotation / 4.0

func _is_currently(state: CardHudBase.State):
	return currently_focused and currently_focused.state == state

func get_position_data_for_cards() -> Array[Dictionary]:
	const angle_card_distance = 0.15
	const angle_hover_distance = 0.3

	@warning_ignore("integer_division")
	var angle_offset: float = -int(len(cards) / 2) * angle_card_distance
	if len(cards) % 2 == 0:
		angle_offset += angle_card_distance / 2.0
	if _is_currently(State.PREVIEWED):
		angle_offset -= angle_hover_distance / 2.0

	var calculated_card_data: Array[Dictionary] = []
	for card: CardHudBase in cards:
		var spread_distance = 0.0
		if card == currently_focused and _is_currently(State.PREVIEWED):
			spread_distance = angle_hover_distance / 2.0

		angle_offset += spread_distance
		var data_dict = {
			position = _calculate_card_position(angle_offset),
			rotation = angle_offset
		}
		angle_offset += spread_distance

		calculated_card_data.push_back(data_dict)
		angle_offset += angle_card_distance

	return calculated_card_data

func _calculate_card_position(angle_offset: float) -> Vector2:
	const up_angle: float = -PI / 2.0
	var center_distance: float = abs(placer_center.position.y)

	return center_distance * Vector2.from_angle(up_angle + angle_offset)
