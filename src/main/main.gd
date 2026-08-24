## This node always stays as a root of the scene tree
class_name Main extends Node

@onready var tooltip_canvas: TooltipCanvas = %TooltipCanvas

static func new_instance() -> Main:
    var main: Main = GameManager.scenes.MAIN_SCENE.instantiate()
    return main
    
func _ready() -> void:
    SignalBus.main_loaded.emit()
    GameManager.main = self