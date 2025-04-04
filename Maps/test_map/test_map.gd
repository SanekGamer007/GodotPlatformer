extends Node2D

func _process(_delta):
	if %player.global_position.y > 640 and %player.state != %player.states.DEAD:
		%player.set_state(%player.states.DEAD)
