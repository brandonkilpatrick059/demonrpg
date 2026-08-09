extends Node

@export var game_state_key : String = ""
@export var to_value : String = ""

func run_script():
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	gamestate.set_state_map_value(game_state_key,to_value)
