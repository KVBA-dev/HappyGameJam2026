## This node always stays as a root of the scene tree
class_name Main extends Node

static func new_instance() -> Main:
    var main: Main = GameManager.scenes.MAIN_SCENE.instantiate()
    return main
    
func _ready() -> void:
    SignalBus.main_loaded.emit()