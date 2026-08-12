extends Node

@export var rain_layer : CanvasLayer
@export var is_raining : bool = true

func run_script():
	if(is_raining):
		rain_layer.set_active()
		rain_layer.visible = true
	else:
		rain_layer.set_inactive()
		rain_layer.visible = false
