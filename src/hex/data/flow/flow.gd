class_name Flow extends Resource


@export var inputs: Array[HexVector.Direction]
@export var outputs: Array[HexVector.Direction]

func rotate(n_60degree: int) -> void:
	for idx in range(len(inputs)):
		inputs[idx] = HexVector.direction_rotate(inputs[idx], n_60degree)

	for idx in range(len(outputs)):
		outputs[idx] = HexVector.direction_rotate(outputs[idx], n_60degree)

func _to_string() -> String:
	return "Inputs(%s), Outputs(%s)" % [inputs, outputs]
