extends Sprite2D

@export var wobble_distance: int = 0
@export var speed : int = 0
@export var step_time_secs : float = 1
@export var vertical : bool = false

var origin : Vector2 = Vector2(0,0)

var timer := Timer.new()

var positive : bool = false

func _ready():
	timer.one_shot = true
	add_child(timer)
	origin = position

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		if(positive):
			if(vertical):
				if(position.y < origin.y + wobble_distance):
					position = position + Vector2(0,speed)
				else:
					positive = false
			else:
				if(position.x < origin.x + wobble_distance):
					position = position + Vector2(speed,0)
				else:
					positive = false
		else:
			if(vertical):
				if(position.y > origin.y - wobble_distance):
					position = position - Vector2(0,speed)
				else:
					positive = true
			else:
				if(position.x > origin.x - wobble_distance):
					position = position - Vector2(speed,0)
				else:
					positive = true
		timer.start(step_time_secs)
			
	
