extends Node2D
@onready var loadlocation: SubViewport = get_node("SubViewportContainer/SubViewport")
@export var sceneonstartup: String


func _ready() -> void:
	var scene: Resource = ResourceLoader.load(sceneonstartup)
	var newscene: Node = scene.instantiate()
	loadlocation.add_child(newscene)
