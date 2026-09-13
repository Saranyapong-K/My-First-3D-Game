# ----------------------------------------------------------------------------------- #
# -------------- FEEL FREE TO USE IN ANY PROJECT, COMMERCIAL OR NON-COMMERCIAL ------ #
# ---------------------- 3D PLATFORMER CONTROLLER BY SD STUDIOS --------------------- #
# ---------------------------- ATTRIBUTION NOT REQUIRED ----------------------------- #
# ----------------------------------------------------------------------------------- #

extends CharacterBody3D

# ---------- VARIABLES ---------- #

@export_category("Player Properties")
@export var move_speed : float = 6
@export var run_speed : float = 10
@export var jump_force : float = 5
@export var max_fall_speed : float = 30.0  # Prevents infinite acceleration in air
@export var follow_lerp_factor : float = 4
@export var jump_limit : int = 2

@export_group("Game Juice")
@export var jumpStretchSize := Vector3(0.8, 1.2, 0.8)

# Booleans
var is_grounded = false
var can_double_jump = false
var is_running = false

# Onready Variables
@onready var model = $"Root Scene"
@onready var animation = $"Root Scene"/AnimationPlayer
@onready var spring_arm = %Gimbal

@onready var particle_trail = $ParticleTrail
@onready var footsteps = $Footsteps

# Get the gravity from project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

# ---------- FUNCTIONS ---------- #

func _process(delta):
	# Handle Jumping Input
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("Jump"):
		if is_grounded:
			perform_jump()
		elif can_double_jump:
			perform_flip_jump()

	player_animations()
	get_input(delta)
	
	# Smoothly follow player's position
	spring_arm.position = lerp(spring_arm.position, position, delta * follow_lerp_factor)
	
	# Player Rotation
	if is_moving():
		var look_direction = Vector2(velocity.z, velocity.x)
		if look_direction.length_squared() > 0.01: # Safe threshold
			model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 12)
	
	# Check if player is grounded
	is_grounded = is_on_floor()
	
	if is_grounded:
		can_double_jump = true

	# Apply gravity with terminal velocity cap
	velocity.y -= gravity * delta
	velocity.y = max(velocity.y, -max_fall_speed)

func perform_jump():
	if AudioManager.jump_sfx:
		AudioManager.jump_sfx.play()
		AudioManager.jump_sfx.pitch_scale = 1.12
	
	jumpTween()
	animation.play("CharacterArmature|Roll", 0.1)
	velocity.y = jump_force

func perform_flip_jump():
	if AudioManager.jump_sfx:
		AudioManager.jump_sfx.play()
		AudioManager.jump_sfx.pitch_scale = 0.8
		
	animation.play("CharacterArmature|Roll", 0.1, 2.0)
	velocity.y = jump_force
	can_double_jump = false

func is_moving():
	return abs(velocity.x) > 0.1 || abs(velocity.z) > 0.1

var scale_tween: Tween

func jumpTween():
	if scale_tween and scale_tween.is_valid():
		scale_tween.kill()
	model.scale = Vector3.ONE # Reset to safe base scale
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(model, "scale", jumpStretchSize, 0.1)
	scale_tween.tween_property(model, "scale", Vector3(1, 1, 1), 0.1)

# Get Player Input
func get_input(_delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_axis("move_left", "move_right")
	move_direction.z = Input.get_axis("move_forward", "move_back")
	
	# Check Shift key for running
	is_running = Input.is_action_pressed("Run") or Input.is_key_pressed(KEY_SHIFT)
	var current_speed = run_speed if is_running else move_speed
   
	# Safety check to prevent 0-vector normalization errors
	if move_direction.length_squared() > 0:
		move_direction = move_direction.normalized()
		move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y)

	velocity = Vector3(move_direction.x * current_speed, velocity.y, move_direction.z * current_speed)

	move_and_slide()

# Handle Player Animations
func player_animations():
	particle_trail.emitting = false
	footsteps.stream_paused = true
	
	if is_on_floor():
		if is_moving():
			if is_running:
				animation.play("CharacterArmature|Run", 0.5)
				particle_trail.emitting = true
				footsteps.stream_paused = false
			else:
				animation.play("CharacterArmature|Walk", 0.5)
				particle_trail.emitting = true
				footsteps.stream_paused = false
		else:
			animation.play("CharacterArmature|Idle", 0.5)
