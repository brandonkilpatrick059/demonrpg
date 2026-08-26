extends Node

@export var nodes : Array[Node] = []
@export var mod : Color

func run_script():
	for node in nodes:
		node.modulate = mod
