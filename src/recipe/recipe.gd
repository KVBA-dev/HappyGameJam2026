class_name Recipe
extends Resource

@export var requirements: Dictionary[ItemData, int]
@export var produces: ItemData
@export var production_capacity: int
@export var processing_time_ticks: int = 10 
