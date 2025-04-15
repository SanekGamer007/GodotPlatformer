extends Camera2D

func _process(delta: float) -> void:
	var cam_subpixel_offset = position.round() - position
	get_tree().root.get_node("Main/SubViewportContainer").material.set_shader_parameter("camera_offset", cam_subpixel_offset)
