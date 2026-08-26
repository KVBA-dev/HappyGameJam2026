class_name FlowHex extends Hex

static func new_instance(
	_hex_position: HexVector,
	_hex_data: HexData,
	appear_style: Hex.AppearStyle = Hex.AppearStyle.Above,
) -> Hex:
	const SCENE := preload("uid://3rxyinjdp8bm")
	var new_hex: Hex = SCENE.instantiate()
	new_hex.hex_data = _hex_data
	new_hex.hex_position = _hex_position
	new_hex.position = _hex_position.to_pixel()
	new_hex._appear_style = appear_style
	return new_hex


func _ready() -> void:
	super._ready()
	if not item_flow:
		push_error("Flow has to be set for flow hex")
