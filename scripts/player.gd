extends CharacterBody3D

@onready var camera_mount: Node3D = $camera_mount
@onready var camera: Node3D = $camera_mount/Camera3D
@onready var camera_ray: Node3D = $camera_mount/Camera3D/RayCast3D
@onready var player_ray: Node3D = $player_ray
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals

var bullet_scene = preload('res://scenes/bullet.tscn')
signal bullet_shot(origin, direction)
var bullet_spray = 0.02

var SPEED = 2.5
const JUMP_VELOCITY = 4.5
var walking_speed = 2.5
var running_speed = 6.0

var running = false

var is_locked = false

var rng = RandomNumberGenerator.new()

@export var sens_horizontal = 0.2
@export var sens_vertical = 0.2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
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
		var bullet = bullet_scene.instantiate()
		add_child(bullet)
		bullet.global_position = player_ray.global_position
		var target_direction = (player_ray.to_global(player_ray.target_position) - player_ray.global_position).normalized()
		var spray = Vector3(rng.randf_range(-bullet_spray, bullet_spray), rng.randf_range(-bullet_spray, bullet_spray), 0)
		bullet.direction = (target_direction + spray).normalized()

	
	if !animation_player.is_playing():
		is_locked=false
	
	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else: 
		SPEED = walking_speed
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running: 
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else: 
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
			#rotate player toward the direction that we are walking
			
			visuals.look_at (position + direction)
			
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
