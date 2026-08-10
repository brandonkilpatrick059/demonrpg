extends Node

@export var nodes : Array[Node] = []

func run_script():
	for node in nodes:
		node.queue_free()
