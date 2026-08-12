extends Node

@export var zone : LocationZone
@export var is_dark : bool = true

func run_script():
	if(is_dark):
		zone.set_is_dark()
	else:
		zone.set_is_not_dark()
