extends Area3D

var SPEED = 10
var direction = Vector3.ZERO
@export var explosion_scene = preload("res://scenes/explosion.tscn") 
@onready var space_state = get_world_3d().direct_space_state

# Called every frame
func _process(delta: float):
	var ray_length = SPEED * delta 
	var ray_end = global_position + direction.normalized() * ray_length

	var query = PhysicsRayQueryParameters3D.new()
	query.from = global_position
	query.to = ray_end
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	if result:
		_on_hit(result.collider, result.position)
	else:
		global_position += direction.normalized() * SPEED * delta 

func _on_hit(collider, collision_point: Vector3):
	if collider is StaticBody3D:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = collision_point

		queue_free()
		
	elif collider is CSGBox3D:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = collision_point
		
		queue_free()
