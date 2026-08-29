class_name TutorialScreen
extends CanvasLayer

@export var screens: Array[Control]

var screen_idx: int = 0

func _input(event: InputEvent) -> void:
	if screen_idx >= len(screens):
		return
	if event.is_action_pressed("pause"):
		screen_idx = len(screens)
		hide()
		refresh()
	if event.is_action_pressed("tutorial_next"):
		screen_idx += 1
		if screen_idx == len(screens):
			hide()
		refresh()

func refresh() -> void:
	var i := 0
	for s: Control in screens:
		s.visible = i == screen_idx
		i += 1
