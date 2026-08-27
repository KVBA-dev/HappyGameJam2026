class_name TextTooltip extends Tooltip

@onready var text_label: Label = %TextLabel
const SCENE := preload("uid://bjwylgmbh648b")
var text: String

static func new_instance(_text: String) -> TextTooltip:
	var tooltip: TextTooltip = SCENE.instantiate()
	tooltip.text = _text
	return tooltip


func _ready() -> void:
	text_label.text = text
