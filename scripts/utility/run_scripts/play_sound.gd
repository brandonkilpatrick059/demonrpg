extends Node

@export var sound_stream : AudioStream = null

func run_script():
	var player : Player = get_tree().get_first_node_in_group("player")
	player.play_sound(sound_stream)
