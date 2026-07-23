extends Node2D

@export var wait_time : float = 0.0

var timer := Timer.new()

func _ready():
	timer.one_shot = true
	add_child(timer)
	timer.start(wait_time)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		queue_free()
