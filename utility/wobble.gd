extends Sprite2D

@export var wobble_distance: int = 0
@export var speed : int = 0
@export var step_time_secs : int = 1
@export var vertical : bool = false

var origin : Vector2 = Vector2(0,0)

var timer := Timer.new()

var positive : bool = false

func _ready():
	timer.one_shot = true
	add_child(timer)
	origin = global_position

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		if(positive):
			if(vertical):
				if(global_position.y < origin.y + wobble_distance):
					global_position = global_position + Vector2(0,speed)
				else:
					positive = false
			else:
				if(global_position.x < origin.x + wobble_distance):
					global_position = global_position + Vector2(speed,0)
				else:
					positive = false
		else:
			if(vertical):
				if(global_position.y > origin.y - wobble_distance):
					global_position = global_position - Vector2(0,speed)
				else:
					positive = true	
			else:
				if(global_position.x > origin.x - wobble_distance):
					global_position = global_position - Vector2(speed,0)
				else:
					positive = true
		timer.start(step_time_secs)
			
	
