extends StaticBody2D

@export var no_gamestate : bool = true
@export var gamestate_key : String = ""
@export var run_if_state : String = ""
@export var default_state : String = ""
@export var scripts : Array[Node] = []

func _ready() -> void:
	add_to_group("interactable")
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	if(gamestate.get_state_map_value(gamestate_key) == "NONE"):
		gamestate.set_state_map_value(gamestate_key,default_state)

func grid_aligned_callback():
	run_scripts()

func run_scripts():
	for script in scripts:
		script.run_script()

func interact():
	if(no_gamestate):
		run_scripts()
	else:
		var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
		var map_value = gamestate.get_state_map_value(gamestate_key)
		if(map_value == run_if_state):
			run_scripts()
		
