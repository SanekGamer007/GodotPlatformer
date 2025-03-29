extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_node("FPS").text = "FPS: " + "%.2f" % (1.0/delta)
	get_node("TimeSinceLastFrame").text = "TSLF: " + "%.4f" % delta + "ms"
