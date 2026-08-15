extends Node2D

var active : bool = false

func set_active():
	active = true

func set_inactive():
	active = false

func is_active() -> bool:
	return active

func _physics_process(delta: float) -> void:
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	global_position = camera.get_screen_center_position()
