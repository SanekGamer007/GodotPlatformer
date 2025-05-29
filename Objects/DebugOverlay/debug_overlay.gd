extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_node("FPS").text = "FPS: " + "%.2f" % Engine.get_frames_per_second() #(1.0/delta)
	get_node("FrameTime").text = "Frametime: " + "%.4f" % delta + "ms"
