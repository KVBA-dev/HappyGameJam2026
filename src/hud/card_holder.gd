class_name CardHolder extends Control

const State = CardHudBase.State 


@onready var cards_container: Node2D = %CardsContainer
@onready var placer_center: Node2D = %PlacerCenter
@onready var card_lay_area: HoverableArea = %CardLayArea
@onready var trash_can = %TrashCan

var _usable_card_limit: int = 2
var _placable_card_limit: int = 4
var _card_num_limit: int = _usable_card_limit + _placable_card_limit

var currently_focused: CardHudBase = null
var cards: Array[CardHudBase] = []
var can_be_laid_down: bool = true

# signal card_destroyed(card: CardHudBase)
signal card_returned_to_hand(card: CardHudBase)
signal card_dragged(card: CardHudBase)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("card_select"):
		if _is_currently(State.DRAGGED) and trash_can.bin_area.hover:
			_trash_card()
		elif _can_use_card():
			var card := take_currently_dragged()
			card.start_use_animation()

func _can_use_card(log_errors: bool = true) -> bool:
	if not _is_currently(State.DRAGGED) or card_lay_area.hover:
		return false

	match currently_focused.card_data.type:
		CardData.Type.PLACABLE: return _can_use_placable(log_errors)
		CardData.Type.USABLE: return _can_use_usable(log_errors)
		_: return false

func _can_use_placable(log_errors: bool = true) -> bool:
	var hovered = Cursor.hover_hex
	if not hovered:
		return false

	if hovered.hex_data.type != HexData.Type.BLANK:
		if log_errors: ErrorBus.hex_already_exist_on_position.emit(hovered.hex_position)
		return false

	var can_place = GameManager.hex_grid.can_place_card(currently_focused, hovered.hex_position, log_errors)
	return can_place

func _can_use_usable(log_errors: bool = true) -> bool:
	var hovered = Cursor.hover_hex
	if not hovered:
		return false
	if hovered.hex_data.type != HexData.Type.FLOW:
		## TODO: Error no card here
		return false

	return true


func is_interacted_with() -> bool:
	if currently_focused == null:
		return false

	return currently_focused.state != State.IN_HAND

func take_currently_dragged() -> CardHudBase:
	var card = currently_focused
	currently_focused.state = State.PLACED
	currently_focused = null
	return card

func _count_usable_in_hand() -> int:
	var count := 0
	for card in cards:
		if card.card_data.type == CardData.Type.USABLE:
			count += 1
	return count

func _can_add_card(card_data: CardData) -> bool:
	var limit = _card_num_limit
	var cards_num = len(cards)

	var usable_in_hand = _count_usable_in_hand()

	match card_data.type:
		CardData.Type.USABLE:
			limit = _usable_card_limit
			cards_num = usable_in_hand
		CardData.Type.PLACABLE:
			limit = _placable_card_limit
			cards_num = cards_num - usable_in_hand
	
	if _is_currently(State.DRAGGED) and currently_focused.card_data.type == card_data.type: cards_num += 1
	return cards_num + 1 <= limit


func add_card(card_data: CardData) -> bool:
	if not _can_add_card(card_data):
		return false

	var visual_scene: CardHudBase 
	match card_data.type:
		CardData.Type.USABLE: visual_scene = preload("uid://iqggdr0ewk2r").instantiate()
		CardData.Type.PLACABLE: visual_scene = preload("uid://xsqqqiydweyl").instantiate()
	cards_container.add_child(visual_scene)
	visual_scene.hex_sprite.init(card_data.hex_data)
	visual_scene.card_data = card_data

	cards.push_front(visual_scene)
	return true

func _ready():
	GameManager.card_holder = self
	for child in cards_container.get_children():
		child.free()

	fill_hand()
	reorder_cards()

func fill_hand():
	add_card(load("res://const_data/cards/special_cards/back_to_hand_card.tres"))
	add_card(load("res://const_data/cards/special_cards/back_to_hand_card.tres"))

	for i in range(_card_num_limit + 4):
		var card_data: CardData = GameManager.cards.pick_random_weighted()
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

func _trash_card():
	var card := take_currently_dragged()
	SignalBus.card_binned.emit(card)
	card.queue_free()

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

func _sort_usable():
	var placable: Array[CardHudBase] = []
	var usable: Array[CardHudBase] = []

	for card in cards:
		match card.card_data.type:
			CardData.Type.USABLE: usable.append(card)
			CardData.Type.PLACABLE: placable.append(card)

	placable.append_array(usable)
	cards = placable

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
	const angle_hover_distance = 0.1

	_sort_usable()

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
