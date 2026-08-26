extends Node2D

var hud_message_scene: PackedScene = preload("uid://c8tblcve0no6e") 

func _ready() -> void:
	ErrorBus.hex_already_exist_on_position.connect(_handle_hex_already_exist_error)

func _handle_hex_already_exist_error(_hex: Hex):
	spawn_cursor_message("Can't place hex; hex already exists here")

func spawn_cursor_message(text: String):
	var hud_message: HudMessage = hud_message_scene.instantiate()

	add_child(hud_message)
	hud_message.global_position = get_global_mouse_position()

	hud_message.show_text(text)
	await get_tree().create_timer(2.0).timeout
	hud_message.slide_out()
