extends StaticBody3D

@export var explosion_scene = preload("res://scenes/explosion.tscn") 
var health = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func hit() -> void:
	health -= 1
	if health <= 0:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		queue_free()
