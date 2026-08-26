class_name HUDLayer extends CanvasLayer

var hud_message_scene: PackedScene = preload("uid://c8tblcve0no6e") 

func show_message_at_cursor(text: String):
	var hud_message: HudMessage = hud_message_scene.instantiate()

	GameManager.main.add_child(hud_message)
	hud_message.position = hud_message.get_global_mouse_position()
	hud_message.show_text(text)
	await get_tree().create_timer(2.0).timeout
	hud_message.slide_out()
