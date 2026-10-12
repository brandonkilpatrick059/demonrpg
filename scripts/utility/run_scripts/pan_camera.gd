extends Node

@export var relative_destination : Vector2 = Vector2(0,0)
@export var speed : float = 1.0

func run_script():
	var player : Player = get_tree().get_first_node_in_group("player")
	player.pan_camera(player.global_position + relative_destination,speed)
