extends Node2D

func _process(_delta: float) -> void:
	if !%player.get_node("PlayerCam"):
		push_error("Cannot find node \"PlayerCam\", touch controls wont work!")
		set_process(false)
		set_visible(false)
	else:
		set_position(%player.get_node("PlayerCam").get_screen_center_position() - get_viewport_rect().size / 2)
