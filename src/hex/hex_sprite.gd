class_name HexSprite extends Node2D

@onready var background_sprite: Sprite2D = %BackgroundSprite
@onready var on_hex_sprite: Sprite2D = %OnHexSprite
@onready var below_sprite: Sprite2D = %BelowSprite

func init(hex_data: HexData):
	background_sprite.texture = hex_data.texture
	on_hex_sprite.texture = hex_data.on_surface_texture
	below_sprite.texture = hex_data.below_texture