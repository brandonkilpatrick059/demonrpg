extends Node

@export var min_speed : float = 0.0
@export var max_speed : float = 1.0

var direction : Vector2

func _ready() -> void:
	var x_speed = randf_range(min_speed,max_speed)
	var y_speed = randf_range(min_speed,max_speed)
	direction = Vector2(x_speed,y_speed)

func _physics_process(delta: float) -> void:
	get_parent().global_position = get_parent().global_position + direction
