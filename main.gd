extends Node2D
@onready var loadlocation = get_node("SubViewportContainer/SubViewport")
@export var sceneonstartup: String


func load_level(level):
	if loadlocation.get_child(0):
		loadlocation.get_child(0).queue_free()
	var s = ResourceLoader.load(level)
	var newscene = s.instantiate()
	loadlocation.add_child(newscene)

func _ready() -> void:
	var s = ResourceLoader.load(sceneonstartup)
	var newscene = s.instantiate()
	loadlocation.add_child(newscene)
	
func _process(delta: float) -> void:
	if (Vector2(get_node("SubViewportContainer/SubViewport").size) != get_viewport().get_visible_rect().size):
		print_debug("Window size changed! from ",
			get_node("SubViewportContainer/SubViewport").size,
			" To ",
			get_viewport().get_visible_rect())
		get_node("SubViewportContainer/SubViewport").size = get_viewport().get_visible_rect().size
