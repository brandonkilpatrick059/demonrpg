extends Node2D

func set_particle(string : String, mod : Color):
	modulate = mod
	$Label.text = string

func _physics_process(delta: float) -> void:
	global_position.y = global_position.y - 0.5
	if(modulate.a == 0.0):
		queue_free()
