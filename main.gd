extends Node2D
@onready var loadlocation: SubViewport = get_node("SubViewportContainer/SubViewport")
@export var sceneonstartup: String


func load_level(level: String) -> void:
	#if loadlocation.get_child(0):
		#loadlocation.get_child(0).queue_free()
	for loadchild: int in range(loadlocation.get_child_count()):
		if loadlocation.get_child(loadchild).name != "Debug":
			loadlocation.get_child(loadchild).queue_free()
	var scene: Resource = ResourceLoader.load(level)
	var newscene: Node2D = scene.instantiate()
	loadlocation.add_child(newscene)

func _ready() -> void:
	var scene: Resource = ResourceLoader.load(sceneonstartup)
	var newscene: Node = scene.instantiate()
	loadlocation.add_child(newscene)
	
func _process(_delta: float) -> void:
	if (Vector2(get_node("SubViewportContainer/SubViewport").size) != get_viewport().get_visible_rect().size):
		print_debug("Window size changed! from ",
			get_node("SubViewportContainer/SubViewport").size,
			" To ",
			get_viewport().get_visible_rect())
		get_node("SubViewportContainer/SubViewport").size = get_viewport().get_visible_rect().size
