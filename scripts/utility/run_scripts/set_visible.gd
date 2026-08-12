extends Node

@export var node : Node
@export var visible : bool = true

func run_script():
	node.visible = visible
