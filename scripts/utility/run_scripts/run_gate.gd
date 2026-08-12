extends Node

@export var gate : Gate
@export var open : bool = true

func run_script():
	if(open):
		gate.open()
	else:
		gate.close()
