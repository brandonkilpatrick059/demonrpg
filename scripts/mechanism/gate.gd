class_name Gate extends Node2D

@export var is_open : bool = false

func _ready() -> void:
	handle_open_close()

func handle_open_close():
	if(is_open):
		$AnimatedSprite2D.play("open")
		$StaticBody2D.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$AnimatedSprite2D.play("closed")
		$StaticBody2D.process_mode = Node.PROCESS_MODE_INHERIT

func gate_is_open() -> bool:
	return is_open

func open():
	is_open = true
	handle_open_close()

func close():
	is_open = false
	handle_open_close()
