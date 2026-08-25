class_name FlowHex extends Hex

func _ready() -> void:
    super._ready()
    if not hex_data.item_flow:
        push_error("Flow has to be set for flow hex")
