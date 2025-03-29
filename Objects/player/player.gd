extends CharacterBody2D

## Player Movement Script.

@export_group("Movement","mv_")
@export var mv_MAX_SPEED: int = 130 ## Max Horizontal player speed.
@export var mv_MAX_VERTICAL_SPEED: int = 380 ## Max Vertical player speed.
@export var mv_INITIAL_JUMP_HEIGHT: int = 120 ## Lowest Jump force.
@export var mv_ADDITIONAL_JUMP_HEIGHT: int = 480 ## Highest Jump force.
@export var mv_CELERATION_STEPS: int = 12 ## How much steps does it require for the player to come to stop / to full speed.
var mv_ACCELERATION: int = mv_MAX_SPEED / mv_CELERATION_STEPS ## Acceleration.
var mv_DECELERATION: int = mv_MAX_SPEED / mv_CELERATION_STEPS ## Deceleration.
var isalive: bool = true

var can_jump: bool ## Defines if the player can jump.


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	#Slope detection
	var slopedata: TileData = GetFloorData(get_node("../Level/grass"))
	if slopedata:
		if slopedata.get_custom_data("slope") == true:
			self.floor_snap_length = 3.0
		else:
			self.floor_snap_length = 0.5
	
	if isalive == false:
		self.floor_snap_length = 0.5
		can_jump = false
		return
	
	if is_on_floor():
		print("can_jump: true")
		can_jump = true 
	else: # When on floor, dont process gravity.
		print("can_jump: false")
		can_jump = false 
		velocity += get_gravity() * delta
	
	# Jumping
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") and can_jump:
		velocity.y = -mv_INITIAL_JUMP_HEIGHT
		print("jumping")
	if velocity.y < 0:
		if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up") and not is_on_floor(): # i have no idea why the fuck it works but it does (fixes a bug when you can do the additional jump force in the air after walking off a platform without jumping)
			velocity.y -= mv_ADDITIONAL_JUMP_HEIGHT * delta
			print("additional jump active")

	# Horizontal Movement
	var direction = Input.get_axis("ui_left","ui_right")
	if direction:
		velocity.x = clamp(velocity.x + mv_ACCELERATION * direction, -mv_MAX_SPEED, mv_MAX_SPEED)
	else:
		#velocity.x -= sign(velocity.x) * mv_DECELERATION
		velocity.x -= mv_DECELERATION * sign(velocity.x)
		if abs(velocity.x) <= 6:
			velocity.x = 0
	#print_debug("DIRECTION: ", direction, " ", "VELOCITY: ", velocity.x)
	velocity.y = clamp(velocity.y, -mv_MAX_VERTICAL_SPEED, mv_MAX_VERTICAL_SPEED)
	move_and_slide()
	
func reset():
	position = Vector2.ZERO
	velocity = Vector2.ZERO
	if get_node("PlayerCam"):
		get_node("PlayerCam").position_smoothing_enabled = false
		get_node("PlayerCam").global_position = global_position
		for n in 2: # wait 2 frames to be sure that the camera gets reset.
			await get_tree().physics_frame
		get_node("PlayerCam").position_smoothing_enabled = true
	self.visible = true
	get_node("Sprite2D").visible = true
	self.set_physics_process(true)
	self.set_process(true)

func GetFloorData(tilemap: Node):
	var pos = tilemap.local_to_map(tilemap.to_local(global_position + Vector2(0, 14)))
	var result: TileData = tilemap.get_cell_tile_data(pos)
	return result


func _on_hurtbox_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	kill()
	
func kill():
	get_node("Sprite2D").visible = false
	get_node("DeathEffect").visible = true
	get_node("DeathEffect").emitting = true
	self.set_physics_process(false)
	if get_node("../RespawnText"):
		get_node("../RespawnText").visible = true
	await get_tree().create_timer(3.0).timeout
	if get_node("../RespawnText"):
		get_node("../RespawnText").visible = false
	reset()
