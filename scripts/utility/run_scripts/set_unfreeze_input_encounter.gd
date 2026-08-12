extends Node

@export var encounter_scene : PackedScene

func run_script():
	var player : Player = get_tree().get_first_node_in_group("player")
	var encounter : Encounter = encounter_scene.instantiate()
	player.set_encounter_on_unfreeze_input(encounter)
