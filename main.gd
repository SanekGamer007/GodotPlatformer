extends Node2D
@onready var loadlocation: SubViewport = get_node("/root/game/SubViewportContainer/SubViewport")

func _ready() -> void:
	enable_edgetoedge()

func load_level(level: String) -> void:
	#for loadchild: int in range(loadlocation.get_child_count()):
		#if loadlocation.get_child(loadchild).name != "Debug":
	#		loadlocation.get_child(loadchild).queue_free()
	for child in loadlocation.get_children():
		if child.name != "Debug":
			child.queue_free()
	var sceneresource: Resource = ResourceLoader.load(level)
	if sceneresource:
		var newscene: Node2D = sceneresource.instantiate()
		if newscene:
			loadlocation.add_child(newscene)
		else:
			print_warn("Failed to instantiate scene: " + level)
	else:
		print_warn("Failed to load scene resource: " + level)
	

func _process(_delta: float) -> void:
	if (Vector2(get_node(^"/root/game/SubViewportContainer/SubViewport").size) != get_viewport().get_visible_rect().size):
		if OS.has_feature("debug"):
			print_debug("Window size changed! from ",
				Vector2i(get_node(^"/root/game/SubViewportContainer/SubViewport").size),
				" To ",
				Vector2i(get_viewport().get_visible_rect().size))
		get_node(^"/root/game/SubViewportContainer/SubViewport").size = get_viewport().get_visible_rect().size

func enable_edgetoedge() -> void: # some really scary code that enables the edge to edge mode on android
	if not OS.has_feature("android") == true:
		print_warn("Running on " + OS.get_name() + OS.get_version_alias() + ", Android's Edge-to-Edge mode request ignored.")
		return
	elif OS.has_feature("debug") == true:
		print_warn("Detected debug feature flag, Edge-to-Edge request ignored.")
		return
	print("Running on ", OS.get_name(), OS.get_version_alias(), ", enabling Edge-to-Edge mode.")
	var android_runtime: JNISingleton
	var window: JavaObject
	var activity: JavaObject
	if Engine.has_singleton("AndroidRuntime"):
		android_runtime = Engine.get_singleton("AndroidRuntime")
		activity = android_runtime.getActivity()
		window = activity.getWindow()
	var layout_params: JavaClass = JavaClassWrapper.wrap("android.view.WindowManager$LayoutParams")

	window.addFlags(layout_params.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
	var callable: Callable = func () -> void:
		var view: JavaClass = JavaClassWrapper.wrap("android.view.View")

		# Allow UI to render behind status bar
		window.getDecorView().setSystemUiVisibility(view.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
		var insets_controller = window.getInsetsController()
		window.setStatusBarColor(Color.TRANSPARENT.to_argb32())
		window.setNavigationBarColor(Color.TRANSPARENT.to_argb32())

		var wic: JavaClass = JavaClassWrapper.wrap("android.view.WindowInsetsController")

		insets_controller.setSystemBarsAppearance(
		0,
		wic.APPEARANCE_LIGHT_STATUS_BARS
		)

	activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(callable))

func print_warn(message: String) -> void:
	print_rich("[color=yellow]", "WARN: ", message)
