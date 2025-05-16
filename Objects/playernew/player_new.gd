extends CharacterBody2D
enum states {
	IDLE, 
	MOVING, 
	JUMPING,
	FALLING, 
	DEAD, 
	DASHING,
	}
var statename: Dictionary = {
	0: "IDLE",
	1: "MOVING",
	2: "JUMPING",
	3: "FALLING",
	4: "DEAD",
	5: "DASHING",
	}
var state: states = states.IDLE

## Player Movement Script.

@export_group("Movement","mv_")
@export var mv_MAX_SPEED: int = 130 ## Max Horizontal player speed.
@export var mv_MAX_DASH_SPEED: int = 150 + mv_MAX_SPEED ## WIP
@export var mv_MAX_VERTICAL_SPEED: int = -240 ## Max Vertical player speed.
@export var mv_MAX_NEGATIVE_VERTICAL_SPEED: int = 360 ## Max Negative Vertical player speed.
@export var mv_INITIAL_JUMP_HEIGHT: int = 120 ## Lowest Jump force.
@export var mv_ADDITIONAL_JUMP_HEIGHT: int = 500 ## Highest Jump force.
@export var mv_CELERATION_STEPS: int = 12 ## How much steps does it require for the player to come to stop / to full speed.
@export var mv_DASHSPEED: Vector2 = Vector2(140, 200) ## WIP
@export var mv_SPEED_REDUCTION_RATE: int = 16 ## WIP
@export var mv_SPEED_REDUCTION_RATE_AIR: int = 4 ## WIP
var mv_ACCELERATION: float = float(mv_MAX_SPEED) / float(mv_CELERATION_STEPS) ## Acceleration.
var mv_DECELERATION: float = float(mv_MAX_SPEED) / float(mv_CELERATION_STEPS) ## Deceleration.

@export_group("Unlocks","un_")
@export var un_Dashing: bool = false ## Ability to dash.

@export var isgod: bool = false
var candash: bool = true ## WIP
var objectkilled: Vector2


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dash"):
		set_state(states.DASHING)
	elif velocity.y > 1:
		set_state(states.FALLING)
	#elif event.is_action_just_pressed("ui_accept"):
	elif Input.is_action_pressed("ui_accept") and is_on_floor():
		set_state(states.JUMPING)
	elif velocity != Vector2.ZERO:
		set_state(states.MOVING)
	else:
		set_state(states.IDLE)

	if is_on_floor():
		candash = true
	#print(statename.get(state), " ", velocity, " ", is_on_floor())
	
	var direction: float = Input.get_axis("left", "right") # TODO: cap the speed depending on how big $direction is.
#	print(direction)
	if direction:
		if not abs(velocity.x) > mv_MAX_SPEED: 
			velocity.x = velocity.x + mv_ACCELERATION * direction # if below max speed add more velocity
		elif is_on_floor():
			velocity.x = (
				#if above max speed start decreasing velocity
				velocity.x + ((sign(velocity.x) * mv_SPEED_REDUCTION_RATE) * -1))
		else:
			velocity.x = velocity.x + ((sign(velocity.x) * mv_SPEED_REDUCTION_RATE_AIR) * -1) #if above max speed start decreasing velocity (air version)
	else:
		velocity.x -= mv_DECELERATION * sign(velocity.x)

	if abs(velocity.x) <= 6 and !direction:
		velocity.x = 0
		
		velocity.x * abs(direction)
		
	# Jumping
	if state == states.JUMPING and is_on_floor():
		velocity.y = -mv_INITIAL_JUMP_HEIGHT
		#print("jumping")
	if velocity.y < 0:
		# i have no idea why the fuck it works but it does
		# (fixes a bug when you can do the additional jump
		# force in the air after walking off a platform without jumping)
		if Input.is_action_pressed("ui_accept") and not is_on_floor() and not state == states.DASHING:
			velocity.y -= mv_ADDITIONAL_JUMP_HEIGHT * delta
			#print("additional jump active")
	if state == states.DASHING and un_Dashing:
		var dashdirection: Vector2 = Input.get_vector("left", "right", "up", "down")
		if abs(dashdirection.y) > 0.1 and Input.is_action_pressed("ui_accept"):
			dashdirection.y = 0.25 * sign(dashdirection.y)
		if abs(velocity + (mv_DASHSPEED * dashdirection)) > Vector2(mv_MAX_DASH_SPEED, mv_MAX_DASH_SPEED):
			velocity = velocity + ((mv_DASHSPEED * dashdirection) / 2.2)
		else:
			velocity = velocity + (mv_DASHSPEED * dashdirection)

	
	velocity += get_gravity() * delta
	velocity.y = clamp(velocity.y, mv_MAX_VERTICAL_SPEED, mv_MAX_NEGATIVE_VERTICAL_SPEED)
	print(direction, " ", velocity)
	move_and_slide()


func set_state(new_state: int) -> void:
	#var previous_state: int = state
	#print(statename.get(previous_state), " ", statename.get(new_state))
	#if previous_state == states.MOVING and new_state == states.DASHING or previous_state == states.FALLING and new_state == states.DASHING:
	if new_state == states.DASHING:
		if not is_on_floor() and candash:
			state = new_state
			candash = false
	elif new_state == states.DEAD:
		state = new_state
		get_node("Sprite2D").visible = false
		get_node("DeathEffect").visible = true
		get_node("DeathEffect").emitting = true
		get_node("DeathEffect/thirdparticles").emitting = true
		if get_node("PlayerCam"):
			print(objectkilled)
			get_node("PlayerCam").global_position = objectkilled
		self.set_physics_process(false)
		if get_node("../RespawnText"):
			get_node("../RespawnText").visible = true
		await get_tree().create_timer(3.0).timeout
		if get_node("../RespawnText"):
			get_node("../RespawnText").visible = false
		reset()
	else:
		state = new_state

func reset() -> void: # -> void means that nothing is going to be returned
	if get_node("../RespawnPoint"):
		position = get_node("../RespawnPoint").position
	else:
		position = Vector2.ZERO
	velocity = Vector2.ZERO
	if get_node("PlayerCam"):
		get_node("PlayerCam").position_smoothing_enabled = false
		get_node("PlayerCam").global_position = global_position
		@warning_ignore("inferred_declaration")
		for frame in 2: # wait 2 frames to be sure that the camera gets reset.
			await get_tree().physics_frame
		get_node("PlayerCam").position_smoothing_enabled = true
	self.visible = true
	get_node("Sprite2D").visible = true
	self.set_physics_process(true)
	self.set_process(true)
	set_state(states.IDLE)
	
	
	
	
	
	
func _on_hurtbox_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	objectkilled = body.to_global(body.map_to_local(body.get_coords_for_body_rid(body_rid)))
	if not isgod:
		set_state(states.DEAD)
