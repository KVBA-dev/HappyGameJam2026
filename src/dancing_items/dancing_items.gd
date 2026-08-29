class_name DancingItems extends PanelContainer


var DANCING_ITEMS: Array[Texture2D] = [
	preload("res://assets/images/tiles_factories/strawberry_factory.png"),
	preload("res://assets/images/tiles_factories/Plantacja_Truskawek.png"),
	preload("res://assets/images/tiles_factories/Cukiernia.png"),
	preload("res://assets/images/tiles_factories/cream_factory.png"),
	preload("res://assets/images/tiles_factories/Plantacja_Wanilli.png"),
	preload("res://assets/images/tiles_factories/vanilla_factory.png"),
	preload("res://assets/images/tiles_factories/Przetwarzanie_Wanilli.png"),
	preload("res://assets/images/tiles_factories/wheat_field.png"),
	preload("res://assets/images/tiles_factories/Krówka.png"),
	preload("res://assets/images/tiles_factories/Piekarnia.png"),
	preload("res://assets/images/tiles_factories/chocolate_factory.png"),
	preload("res://assets/images/tiles_factories/Lodziarnia.png"),
	preload("res://assets/images/tiles_factories/Mleczarnia.png"),
	preload("res://assets/images/items/strawberry.png"),
	preload("res://assets/images/items/chocolate.png"),
	preload("res://assets/images/items/beetroot.png"),
	preload("res://assets/images/items/vanilla.png"),
	preload("res://assets/images/items/flour.png"),
	preload("res://assets/images/items/sugar.png"),
	preload("res://assets/images/items/ice.png"),
	preload("res://assets/images/items/icecream_cream.png"),
	preload("res://assets/images/items/water.png"),
	preload("res://assets/images/items/ethane.png"),
	preload("res://assets/images/items/icecream_strawberry.png"),
	preload("res://assets/images/items/vanilla_extract.png"),
	preload("res://assets/images/items/milk.png"),
	preload("res://assets/images/items/cone.png"),
	preload("res://assets/images/items/icecream_chocolate.png"),
	preload("res://assets/images/items/strawberry_juice.png"),
	preload("res://assets/images/items/cream.png"),
	preload("res://assets/images/items/coco_powder.png"),
	preload("res://assets/images/items/icecream_tricolor.png"),
	preload("res://assets/images/items/icecream_vanilla.png"),
	preload("res://assets/images/items/wheat.png"),
	preload("res://assets/images/items/cocoa_fruit.png"),
]

var items: Dictionary[Sprite2D, float] = {}

const TRAVEL_TIME: float = 12.0

func _ready() -> void:
	while true:
		DANCING_ITEMS.shuffle()
		for item: Texture2D in DANCING_ITEMS:
			var sprite: Sprite2D = Sprite2D.new()
			sprite.hide()
			sprite.texture = item
			var r_scale = 0.35
			sprite.scale = Vector2(r_scale, r_scale)
			add_child(sprite)
			items[sprite] = 0.0
			await get_tree().create_timer(2).timeout

func _process(delta: float) -> void:
	for sprite in items.keys():
		var time: float = items[sprite]
		time += delta
		sprite.global_position.y = global_position.y + size.y * 0.5 + sin(time * 4.0) * 20.0
		sprite.position.x = (size.x + 600) * time / TRAVEL_TIME - sprite.texture.get_size().x * 0.5 - 200
		sprite.rotation = sin(time * 2.0) * 0.1
		if time > TRAVEL_TIME:
			sprite.queue_free()
			items.erase(sprite)
		else:
			items[sprite] = time
		sprite.show()