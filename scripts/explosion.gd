extends Node3D

@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready():
	animated_sprite.play("explosion") 

func _on_animated_sprite_3d_animation_finished() -> void:
	queue_free()
