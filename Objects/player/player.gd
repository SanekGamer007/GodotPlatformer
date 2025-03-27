extends CharacterBody2D

## Player Movement Script.

@export_group("Movement","mv_")
@export var mv_MAX_SPEED: int = 150 ## Max Horizontal player speed.
@export var mv_MAX_VERTICAL_SPEED: int = 380 ## Max Vertical player speed.
@export var mv_INITIAL_JUMP_HEIGHT: int = 120 ## Lowest Jump force.
@export var mv_ADDITIONAL_JUMP_HEIGHT: int = 480 ## Highest Jump force.
@export var mv_CELERATION_STEPS: int = 12 ## How much steps does it require for the player to come to stop / to full speed.
var mv_ACCELERATION: int = mv_MAX_SPEED / mv_CELERATION_STEPS ## Acceleration.
var mv_DECELERATION: int = mv_MAX_SPEED / mv_CELERATION_STEPS ## Deceleration.

var can_jump: bool ## Defines if the player can jump.


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if is_on_floor():
		can_jump = true 
	else: # When on floor, dont process gravity.
		velocity += get_gravity() * delta
	
	# Jumping
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") and can_jump:
		velocity.y = -mv_INITIAL_JUMP_HEIGHT
	if velocity.y < 0:
		if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up") and can_jump:
			print_debug("aaa ")
			velocity.y -= mv_ADDITIONAL_JUMP_HEIGHT * delta
		if Input.is_action_just_released("ui_accept") or Input.is_action_just_released("ui_up"):
			can_jump = false
	
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
