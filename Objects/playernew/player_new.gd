extends CharacterBody2D
enum states {
	IDLE, 
	MOVING, 
	JUMPING,
	FALLING, 
	DEAD, 
	DASHING,
	}
var statename = {
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
@export var mv_NV_MAX_VERTICAL_SPEED: int = 360 ## Max Negative Vertical player speed.
@export var mv_INITIAL_JUMP_HEIGHT: int = 120 ## Lowest Jump force.
@export var mv_ADDITIONAL_JUMP_HEIGHT: int = 500 ## Highest Jump force.
@export var mv_CELERATION_STEPS: int = 12 ## How much steps does it require for the player to come to stop / to full speed.
@export var mv_DASHSPEED: Vector2 = Vector2(140, 200) ## WIP
@export var mv_SPEED_REDUCTION_RATE: int = 16 ## WIP
@export var mv_SPEED_REDUCTION_RATE_AIR: int = 4 ## WIP
@export var isgod: bool = false
var mv_ACCELERATION: int = mv_MAX_SPEED / mv_CELERATION_STEPS ## Acceleration.
var mv_DECELERATION: int = mv_MAX_SPEED / mv_CELERATION_STEPS ## Deceleration.
var candash: bool = true ## WIP


func _physics_process(delta: float) -> void:
	if is_on_floor():
		candash = true
	#print(statename.get(state), " ", velocity, " ", is_on_floor())
	if Input.is_action_just_pressed("dash"):
		set_state(states.DASHING)
	elif velocity.y > 1:
		set_state(states.FALLING)
	#elif Input.is_action_just_pressed("ui_accept"):
	elif Input.is_action_pressed("ui_accept") and is_on_floor():
		set_state(states.JUMPING)
	elif velocity != Vector2.ZERO:
		set_state(states.MOVING)
	else:
		set_state(states.IDLE)
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if not abs(velocity.x) > mv_MAX_SPEED: 
			velocity.x = velocity.x + mv_ACCELERATION * direction # if below max speed add more velocity
		elif is_on_floor():
			velocity.x = (
				#if above max speed start decreasing velocity
				velocity.x + ((sign(velocity.x) * mv_SPEED_REDUCTION_RATE) * -1))
		else:
			velocity.x = velocity.x + ((sign(velocity.x) * mv_SPEED_REDUCTION_RATE_AIR) * -1) #if above max speed start decreasing velocity
	else:
		velocity.x -= mv_DECELERATION * sign(velocity.x)

	if abs(velocity.x) <= 6:
		velocity.x = 0
	
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
	if state == states.DASHING:
		var dashdirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		print(abs(velocity + (mv_DASHSPEED * dashdirection)))
		if abs(dashdirection.y) > 0.1 and Input.is_action_pressed("ui_accept"):
			print("AA")
			dashdirection.y = 0.25 * sign(dashdirection.y)
		if abs(velocity + (mv_DASHSPEED * dashdirection)) > Vector2(mv_MAX_DASH_SPEED, mv_MAX_DASH_SPEED):
			velocity = velocity + ((mv_DASHSPEED * dashdirection) / 2.2)
		else:
			velocity = velocity + (mv_DASHSPEED * dashdirection)
		print(dashdirection)

	
	velocity += get_gravity() * delta
	velocity.y = clamp(velocity.y, mv_MAX_VERTICAL_SPEED, mv_NV_MAX_VERTICAL_SPEED)

	move_and_slide()


func set_state(new_state: int) -> void:
	var previous_state := state
	#print(statename.get(previous_state), " ", statename.get(new_state))
	#if previous_state == states.MOVING and new_state == states.DASHING or previous_state == states.FALLING and new_state == states.DASHING:
	if new_state == states.DASHING:
		#if is_on_floor():
			#if get_node("DashTimer").is_stopped() == true:
				#get_node("DashTimer").start(0.3)
				#state = new_state
				#candash = false
				#return
			#else:
			#return
		if not is_on_floor() and candash:
			state = new_state
			candash = false
	elif new_state == states.DEAD:
		state = new_state
		get_node("Sprite2D").visible = false
		get_node("DeathEffect").visible = true
		get_node("DeathEffect").emitting = true
		if get_node("PlayerCam"):
			get_node("PlayerCam").global_position = global_position - Vector2(7,7)
		self.set_physics_process(false)
		if get_node("../RespawnText"):
			get_node("../RespawnText").visible = true
		await get_tree().create_timer(3.0).timeout
		if get_node("../RespawnText"):
			get_node("../RespawnText").visible = false
		reset()
	else:
		state = new_state

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
	set_state(states.IDLE)
	
	
	
	
	
	
	


func _on_hurtbox_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if not isgod:
		set_state(states.DEAD)
