extends Node2D

func _process(_delta: float) -> void:
	if !%player.get_child(0):
		push_error("Cannot Find %PlayerCam, Touch Controls wont work!")
		set_process(false)
		set_visible(false)
	else:
		set_position(%player.get_child(2).get_screen_center_position() - get_viewport_rect().size / 2)
