extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready():
	particles.restart()
