class_name Flow extends Resource


@export var inputs: Array[HexVector.Direction]
@export var outputs: Array[HexVector.Direction]

func rotate(n_60degree: int) -> void:
	for idx in range(len(inputs)):
		inputs[idx] = HexVector.direction_rotate(inputs[idx], n_60degree)

	for idx in range(len(outputs)):
		outputs[idx] = HexVector.direction_rotate(outputs[idx], n_60degree)

func _to_string() -> String:
	var inputs_str: String = " "
	var outputs_str: String = " "
	for input_dir in inputs:
		inputs_str += HexVector.dir_to_str(input_dir) + " "
	for output_dir in outputs:
		outputs_str += HexVector.dir_to_str(output_dir) + " "
	return "Inputs(%s), Outputs(%s)" % [inputs_str, outputs_str]
