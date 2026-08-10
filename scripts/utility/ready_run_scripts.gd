extends Node

@export var gamestate_key : String = ""
@export var run_if_state : String = ""
@export var scripts : Array[Node] = []

func _ready() -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	var map_value = gamestate.get_state_map_value(gamestate_key)
	if(map_value == run_if_state):
		run_scripts()

func run_scripts():
	for script in scripts:
		script.run_script()
		
