extends CanvasLayer
@export var fastfpsupd: bool = true ## When true: FPS info updates every frame without stabilisation. When false: FPS info updates once a second with stabilisation. 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fastfpsupd == true:
		get_node("FPS").text = "FPS: " + "%.2f" % (1.0/delta)
	else:
		get_node("FPS").text = "FPS: " + "%.2f" % Engine.get_frames_per_second() 
	get_node("FrameTime").text = "Frametime: " + "%.4f" % delta + "ms"
