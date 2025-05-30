extends Node2D
@export var startupscene: String


func _ready() -> void:
	main.load_level(startupscene)
