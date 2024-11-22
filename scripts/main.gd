extends Node3D

var bullet_scene = preload('res://scenes/bullet.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_bullet_shot(origin:Variant, direction:Variant) -> void:
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = origin
	bullet.direction = direction
