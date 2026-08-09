extends Area2D

@export var gamestate_key : String = ""
@export var run_if_state : String = ""
@export var default_state : String = ""
@export var run_scripts : Array[Node] = []

func _ready() -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	if(gamestate.get_state_map_value(gamestate_key) == "NONE"):
		gamestate.set_state_map_value(gamestate_key,default_state)

func grid_aligned_callback():
	for script in run_scripts:
		script.run_script()
	

func _on_body_entered(body: Node2D) -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	var map_value = gamestate.get_state_map_value(gamestate_key)
	if(map_value == run_if_state):
		if(body.is_in_group("player")):
			body.set_grid_aligned_callback(self)
