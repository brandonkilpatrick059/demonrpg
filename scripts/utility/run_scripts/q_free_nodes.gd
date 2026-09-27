extends Node

@export var nodes : Array[Node] = []

func run_script():
	for node in nodes:
		if(node != null):
			node.queue_free()
