extends MeshInstance3D
var SPEED = 0.1
var direction = Vector3.ZERO

func _ready():
	await get_tree().create_timer(5).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * SPEED
