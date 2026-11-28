extends Node

@export var add_node : Node = null
@export var fade_to : Color
@export var time_step : float = 0.2
@export var fade_step: float = 0.2

func run_script():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	fade_node.set_target_modulate(fade_to, fade_step, time_step)
	add_node.add_child(fade_node)
