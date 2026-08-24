class_name CardHolder extends Control

@onready var cards_container: Node2D = %CardsContainer
@onready var placer_center: Node2D = %PlacerCenter

var currently_focused: CardHudHighlight = null

func _process(_delta: float) -> void:
	var closest := find_closest_hovered()
	_set_currently_focused(closest)

func _set_currently_focused(node: CardHudHighlight):
	if currently_focused:
		currently_focused.state = CardHudHighlight.State.IN_HAND

	if node:
		node.state = CardHudHighlight.State.PREVIEWED

	currently_focused = node
	reorder_cards()

func find_closest_hovered() -> CardHudHighlight:
	var closest: CardHudHighlight = null
	var best_distance: float = INF
	for card: CardHudHighlight in get_cards():
		if card.hover == false:
			continue

		var distance: float = card.global_position.distance_to(get_global_mouse_position())
		if distance < best_distance:
			closest = card
			best_distance = distance
	return closest

func _ready() -> void:
	reorder_cards()

func get_cards() -> Array[Node]:
	return cards_container.get_children()

func reorder_cards() -> void:
	var cards_position_data := get_position_data_for_cards()

	var cards: Array = cards_container.get_children()
	for idx in range(len(cards)):
		cards[idx].position = cards_position_data[idx].position
		cards[idx].rotation = cards_position_data[idx].rotation / 2.0

func get_position_data_for_cards() -> Array[Dictionary]:
	const up_angle: float = -PI / 2.0

	var cards := get_cards()
	var center_distance: float = abs(placer_center.position.y)

	const angle_card_distance = 0.15
	const angle_hover_distance = 0.3

	@warning_ignore("integer_division")
	var angle_offset: float = -int(len(cards) / 2) * angle_card_distance
	if len(cards) % 2 == 0:
		angle_offset += angle_card_distance / 2.0
	if currently_focused:
		angle_offset -= angle_hover_distance / 2.0

	var calculated_card_data: Array[Dictionary] = []
	for card: Node in cards:
		if card == currently_focused:
			angle_offset += angle_hover_distance / 2.0

		var data_dict = {
			position = center_distance * Vector2.from_angle(up_angle + angle_offset),
			rotation = angle_offset / 2.0
		}

		if card == currently_focused:
			angle_offset += angle_hover_distance / 2.0

		calculated_card_data.push_back(data_dict)
		angle_offset += angle_card_distance

	return calculated_card_data
