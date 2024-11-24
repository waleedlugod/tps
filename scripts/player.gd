extends CharacterBody3D

@onready var camera_mount: Node3D = $camera_mount
@onready var camera: Node3D = $camera_mount/Camera3D
@onready var camera_ray: Node3D = $camera_mount/Camera3D/RayCast3D
@onready var player_ray: Node3D = $player_ray
@onready var animation_player = $visuals/model/AnimationPlayer
@onready var visuals = $visuals

signal bullet_shot(origin, direction)
var bullet_spray = 0.02

var SPEED = 2.5
const JUMP_VELOCITY = 4.5
var walking_speed = 2.5
var running_speed = 6.0

var running = false
var is_shooting = false
var is_locked = false

var rng = RandomNumberGenerator.new()

@export var sens_horizontal = 0.2
@export var sens_vertical = 0.2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visuals.rotation_degrees.y = 180
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))
		#so that the player doesnt face where the camera moves
		#visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))
	

func _physics_process(delta: float) -> void:
	if camera_ray.is_colliding(): player_ray.target_position = player_ray.to_local(camera_ray.get_collision_point())
	else: player_ray.target_position = player_ray.to_local(camera_ray.to_global(camera_ray.target_position))

	if Input.is_action_pressed("shoot"):
		if animation_player.current_animation != "shoot":
			animation_player.play("shoot")
			is_locked = true
		var target_direction = (player_ray.to_global(player_ray.target_position) - player_ray.global_position).normalized()
		var spray = Vector3(0, rng.randf_range(-bullet_spray, bullet_spray), rng.randf_range(-bullet_spray, bullet_spray))
		var final_direction = (target_direction + spray).normalized()
		bullet_shot.emit(player_ray.global_position, final_direction)
	else:
		# If shoot input is not pressed then return to idle animation
		if animation_player.current_animation == "shoot":
			animation_player.stop()
			animation_player.play("idle") 
			is_locked=false
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else: 
		SPEED = walking_speed
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != "forward":
					animation_player.play("forward")
					print("running")
			else:
				if input_dir.x < 0:
					if animation_player.current_animation != "left":
						animation_player.play("left")
						print("left")
				elif input_dir.x > 0: 
					if animation_player.current_animation != "right":
						animation_player.play("right")
						print("right")
				elif input_dir.y < 0:  # Moving backward
					if animation_player.current_animation != "backward":
						animation_player.play("backward")
						print("backward")
				else:  # Regular forward movement
					if animation_player.current_animation != "forward":
						animation_player.play("forward")
						print("forward")

			if input_dir.y > 0:  # Only rotate when moving forward
				visuals.look_at(position + global_transform.basis.z, Vector3.UP)

			
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
				
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if !is_locked:
		move_and_slide()
