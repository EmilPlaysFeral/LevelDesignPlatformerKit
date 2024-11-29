extends CharacterBody3D

signal coin_collected
signal reached_goal

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var glide_strength = 0.7  # The reduced gravity during glide
@export var glide_delay = 0.2  # Delay before gliding can start after jumping (in seconds)
@export var glide_powerup_duration = 15.0  # Duration in seconds for the glide ability

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0
var gliding = false  # Flag to check if the player is gliding
var has_glide = false  # Flag to check if the player can glide
var glide_timer_active = false  # Whether the powerup timer is running
var glide_timer_remaining = 0.0  # Time left on the glide timer
var glide_timer = 0.0  # Timer for glide delay

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0
var latest_checkpoint: Vector3

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer
@onready var glide_progress_bar: ProgressBar = $"../HUD/GlideProgressBar"


func _ready() -> void:
	latest_checkpoint = global_position

func _physics_process(delta):
	# Handle timer for glide powerup
	if glide_timer_active:
		glide_timer_remaining -= delta
		if glide_timer_remaining <= 0:
			disable_glide_powerup()

	# Update progress bar
	if glide_timer_active:
		glide_progress_bar.visible = true
		glide_progress_bar.value = glide_timer_remaining  # Update progress bar value
	else:
		glide_progress_bar.visible = false

	# Handle functions
	handle_controls(delta)
	handle_gravity(delta)
	handle_effects(delta)

	# Movement
	var applied_velocity: Vector3

	if gliding:
		gravity = gravity * glide_strength  # Apply reduced gravity while gliding
		movement_velocity.y = 0  # Prevent vertical velocity changes during glide
	else:
		movement_velocity.y = gravity

	# Smooth the velocity and apply it to the player
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity  # Ensure gravity is applied in non-glide state

	velocity = applied_velocity
	move_and_slide()

	# Rotation
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

	# Animation for scale (jumping and landing)
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

	# Animation when landing
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")

	previously_floored = is_on_floor()

	# Update the glide delay timer
	if glide_timer > 0:
		glide_timer -= delta

# Handle animation(s)
func handle_effects(delta):
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.05:
			if animation.current_animation != "walk":
				animation.play("walk", 0.1)

			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor

			if speed_factor > 0.75:
				particles_trail.emitting = true

		elif animation.current_animation != "idle":
			animation.play("idle", 0.1)
	elif animation.current_animation != "jump":
		animation.play("jump", 0.1)

# Handle movement input
func handle_controls(delta):
	# Movement
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	input = input.rotated(Vector3.UP, view.rotation.y)

	if input.length() > 1:
		input = input.normalized()

	movement_velocity = input * movement_speed * delta

	# Jumping and Gliding
	if Input.is_action_just_pressed("jump"):
		if jump_single or jump_double:
			jump()

	# Glide activation (hold jump while in the air and after glide_delay)
	if !is_on_floor() and Input.is_action_pressed("jump") and !gliding and has_glide and glide_timer <= 0:
		enter_glide()

	# Glide deactivation (release jump or reach the ground)
	if gliding and (!Input.is_action_pressed("jump") or is_on_floor()):
		exit_glide()

# Handle gravity
func handle_gravity(delta):
	gravity += 25 * delta
	if gravity > 0 and is_on_floor():
		jump_single = true
		gravity = 0

# Jumping
func jump():
	Audio.play("res://sounds/jump.ogg")
	gravity = -jump_strength
	model.scale = Vector3(0.5, 1.5, 0.5)

	if jump_single:
		jump_single = false
		jump_double = true
	else:
		jump_double = false

	# Start the glide delay timer
	glide_timer = glide_delay

# Glide entry
func enter_glide():
	gliding = true
	Audio.play("res://sounds/glide_start.ogg")  # Optional sound for glide start

# Glide exit
func exit_glide():
	gliding = false
	Audio.play("res://sounds/glide_end.ogg")  # Optional sound for glide end

# Collect glide powerup
func collect_glide_powerup():
	has_glide = true
	glide_timer_active = true
	glide_timer_remaining = glide_powerup_duration  # Start the 15-second timer
	Audio.play("res://sounds/glide_powerup.ogg")  # Optional sound

# Disable glide powerup
func disable_glide_powerup():
	has_glide = false
	glide_timer_active = false
	glide_timer_remaining = 0.0
	exit_glide()  # Ensure gliding is stopped
	Audio.play("res://sounds/powerup_end.ogg")  # Optional sound for powerup end

# Collecting coins
func collect_coin():
	coins += 1
	coin_collected.emit(coins)

func touched_goal() -> void:
	reached_goal.emit()

func player_died() -> void:
	global_position = latest_checkpoint
	disable_glide_powerup()  # Reset the glide ability on death

func reached_checkpoint(checkpoint_pos: Vector3) -> void:
	latest_checkpoint = checkpoint_pos
