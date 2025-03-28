extends RayCast2D

func _process(_delta: float) -> void:
	if is_colliding() == true:
		print(get_collider())
