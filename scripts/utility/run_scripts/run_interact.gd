extends Node

@export var interact_node : Node

func run_script():
	var player : Player = get_tree().get_first_node_in_group("player")
	player.interact_with(interact_node)
