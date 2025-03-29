extends Node2D

func _process(_delta):
	if %player.global_position.y > 640:
		%player.kill()
