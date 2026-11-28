extends Node
@export var scripts : Array[Node] = []

func run_script():
	for script in scripts:
		script.run_script()
