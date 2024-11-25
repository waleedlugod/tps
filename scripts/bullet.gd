extends Area3D

var SPEED = 10
var direction = Vector3.ZERO
@export var explosion_scene = preload("res://scenes/explosion.tscn") 
@onready var space_state = get_world_3d().direct_space_state

# Called every frame
func _process(delta: float):
	if has_overlapping_bodies():
		_on_hit(get_overlapping_bodies()[0])
	else:
		global_position += direction * SPEED * delta 

func _on_hit(collider):
	if collider is StaticBody3D or collider is CSGBox3D:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position - direction * 0.1
		if collider.has_method('hit'): collider.hit()

		queue_free()
